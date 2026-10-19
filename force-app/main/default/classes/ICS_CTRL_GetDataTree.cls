/**
 * @description                 : Class needed by Application flow stories to create hierarchical data retrieval tree from query
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 28-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

 public without sharing class ICS_CTRL_GetDataTree {
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GetDataTree');

    /**
     * @description                 : Node to store the parent, record and children
     * @author                      : Tushar Walse
     * @date                        : 20-03-2024
     * @last modified on            : 28-05-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    public with sharing class Node {
        Map<String, Node> parentNode;
        public SObject record;
        public String type;
        public Map<String, Node[]> childNodes;
        String[] childObjectsPreferred = new String[]{'Group'};

    
        /**
        * @description Constructor to initialize the Node instance
        * @author Tushar Walse | 23-09-2024 
        **/
        public Node() {
            parentNode = new Map<String, Node>();
            childNodes = new Map<String, Node[]>();
        }

        /**
         * @description Get linked nodes by object name looked for in parent first
         * @param objectName Name of the object nodes to retrieve
         * @return Node[] List of nodes with records of the specified object
         */        
        public Node[] getLinkedNodes(String objectName) {
            Node[] nodes;
            if(childObjectsPreferred.contains(objectName)) {
                if(childNodes.containsKey(objectName)) {
                    nodes = childNodes.get(objectName);
                } else {
                    nodes = new Node[]{parentNode.get(objectName)};
                }
            } else {
                if(parentNode.containsKey(objectName)) {
                    nodes = new Node[]{parentNode.get(objectName)};
                } else {
                    nodes = childNodes.get(objectName);
                }
            }
            nodes = nodes == null ? new Node[]{} : nodes;
            return nodes;
        }
    }

    public Node root;
    public Map<Id, Node[]> toNodes;
    public Map<String, Node[]> toNodesByType;
    public Map<String, Set<Id>> toIds = new Map<String, Set<Id>>();
    Map<Id, String> toType = new Map<Id, String>();

    /**
     * @description Constructor to initialize the Tree instance
     */
    public ICS_CTRL_GetDataTree() {
        root = new Node();
        toNodes = new Map<Id, Node[]>();
        toNodesByType = new Map<String, Node[]>();
    }

    /**
    * @description Attach records as children to root nodes
    * @author Tushar Walse | 23-09-2024 
    * @param sObjects Child records to be attached
    * @param type The name of the child object under which children will be attached
    **/
    public void addRootNodes(SObject[] sObjects, String type) {
        attach(root, sObjects, type);
    }

    /**
     * @description Maintain maps of id vs nodes, Object name vs nodes, Object name vs Id list
     * @param node Node to register
     * @return void
     */
    public void register(Node node) {
        try {
            Id id = node.record.Id;
            if(!toNodes.containsKey(id)) {
                toNodes.put(id, new Node[]{});
            }
            toNodes.get(id).add(node);
            if(!toNodesByType.containsKey(node.type)) {
                toNodesByType.put(node.type, new Node[]{});
            }
            toNodesByType.get(node.type).add(node);
            if(!toIds.containsKey(node.type)) {
                toIds.put(node.type, new Set<Id>());
            }
            toIds.get(node.type).add(node.record.Id);
        } catch (Exception e) {
            LOGGER.error('Error in register: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
     * @description Attach child node with value specified in sObj
     * @param sObj Child node record
     * @param type The name of the child object under which children will be attached
     */
    public void attach(Node node, SObject sObj, String type) {
        try {
            Node child;
            if(toNodes.containsKey(sObj.Id)) {
                child = toNodes.get(sObj.Id)[0];
                child.parentNode.put(node.type, node);
            } else {
                child = new Node();
                child.record = sObj;
                child.parentNode.put(node.type, node);
                child.type = type;
                register(child);
            }
            if(!node.childNodes.containsKey(type)) {
                node.childNodes.put(type, new Node[]{});
            }
            node.childNodes.get(type).add(child);
        } catch (Exception e) {
            LOGGER.error('Error in attach: {0}', new Object[]{e.getMessage()});
        }
    }
    
    /**
    * @description create child nodes with values sObjects
    * @author Tushar Walse | 23-09-2024 
    * @param node Parent node to attach the children to
    * @param sObjects List of child records to be attached
    * @param type The name of the child object under which children will be attached
    **/
    public void attach(Node node, SObject[] sObjects, String type) {
        try {
            Node[] nodes = new Node[]{};
            for(SObject sObj : sObjects) {
                attach(node, sObj, type);
            }
        } catch (Exception e) {
            LOGGER.error('Error in attach: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Attach childNodes to parent nodes having Id as specified in parentId
    * @author Tushar Walse | 23-09-2024 
    * @param parentId The Id used to retrieve parent nodes
    * @param childNodes Child nodes to be attached
    * @param type The name of the child object under which children will be attached
    **/
    public void addNodes(Id parentId, SObject[] childNodes, String type) {
        try {
            for(Node node : toNodes.get(parentId)) {
                attach(node, childNodes, type);
            }
        } catch (Exception e) {
            LOGGER.error('Error in addNodes: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Get the object name of the record
    * @author Tushar Walse | 23-09-2024 
    * @param s Record whose object name is to be retrieved
    * @return String containing the object name
    **/
    public String getType(SObject s) {
        try {
            return getType(s.Id);
        } catch (Exception e) {
            LOGGER.error('Error in getType: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
    * @description Get the object name from the Id
    * @author Tushar Walse | 23-09-2024 
    * @param id The id whose object name is to be retrieved
    * @return String The name of the object
    **/
    public String getType(Id id) {
        try {
            String result;
            if(toNodes.containsKey(id)) {
                result = toNodes.get(id)[0].type;
            } else if(toType.containsKey(id)) {
                result = toType.get(id);
            } else {
                result = id.getSobjectType().getDescribe().getName();
                toType.put(id, result);
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getType: {0}\nline: {1}\n{2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }
}