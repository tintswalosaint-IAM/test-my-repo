/**
 * @description                 : Class needed by Application flow stories to create hierarchical tree from query
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 16-03-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

 public without sharing class ICS_CTRL_GetBrowseTree {
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GetBrowseTree');

    /**
     * @description                 : Node class to store parent node, data node and child nodes
     * @author                      : Tushar Walse
     * @date                        : 20-03-2024
     * @last modified on            : 16-03-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    public with sharing class BrowseNode {
        Map<Integer, BrowseNode> parentNode;
        public ICS_CTRL_GetDataTree.Node dataNode;
        public Map<Integer, BrowseNode[]> childNodes;
        Integer lastLevel;

        /**
        * @description Constructor to initialize the Tree instance
        * @author Tushar Walse | 23-09-2024 
        **/
        public BrowseNode() {
            parentNode = new Map<Integer, BrowseNode>();
            childNodes = new Map<Integer, BrowseNode[]>();
        }

        /**
        * @description Constructor to initialize the Tree instance when node is provided
        * @author Tushar Walse | 23-09-2024 
        * @param node Data node to be initialized with
        **/
        public BrowseNode(ICS_CTRL_GetDataTree.Node node) {
            this();
            dataNode = node;
        }

        /**
        * @description Constructor call with data node, level where browse node reappears, browse node
        * @author Tushar Walse | 23-09-2024 
        * @param node Data node to be initialized with
        * @param currentLevel Level at which browse node reappears
        * @param leaf reference to Browse node that reappears
        **/
        public BrowseNode(ICS_CTRL_GetDataTree.Node node, Integer currentLevel, BrowseNode leaf) {
            this(node);
            parentNode.put(currentLevel, leaf);
            lastLevel = currentLevel;
        }

        /**
        * @description Get the parent SObject
        * @author Tushar Walse | 23-09-2024 
        * @param objects Parent, Parent's parent... to reach the last parent
        * @return SObject The parent object record to be returned
        **/
        public SObject getAscendantUsed(String[] objects) {
            try {
                BrowseNode browseNode = this;
                Integer backLevel = browseNode.lastLevel;
                for(String obj : objects) {
                    if(obj != browseNode.parentNode.get(backLevel).dataNode.type) {
                        throw new IllegalArgumentException('getAscendantUsed: mismatch: ' + obj + ' vs ' + browseNode.parentNode.get(backLevel).dataNode.type);
                    }
                    browseNode = browseNode.parentNode.get(backLevel);
                    backLevel--;
                }
                return browseNode.dataNode.record;
            } catch (Exception e) {
                LOGGER.error('Error in getAscendantUsed: {0}\nline: {1}\nobjects: ', new Object[]{e.getMessage(), e.getLineNumber(), JSON.serialize(objects)});
                return null;
            }    
        }
    }

    public BrowseNode[] roots;
    public BrowseNode[] leaves;
    public ICS_CTRL_GetDataTree dataTree;
    Integer currentLevel = -1;
    Integer backLevel;

    /**
    * @description Constructor to initialize the Browse tree instance with data tree instance
    * @author Tushar Walse | 23-09-2024 
    * @param objectName Reference to the data tree instance
    **/
    public ICS_CTRL_GetBrowseTree(ICS_CTRL_GetDataTree pDataTree) {
        dataTree = pDataTree;
    }

    /**
    * @description Initialize the browse tree with root nodes from object with name
    * @author Tushar Walse | 23-09-2024 
    * @param objectName Name of the object from which root nodes are to be created
    **/
    public void init(String objectName) {
        try {
            currentLevel++;
            roots = new BrowseNode[]{};
            if(!dataTree.toNodesByType.containsKey(objectName)) {
                leaves = roots;
                return;
            }
            for(ICS_CTRL_GetDataTree.Node node : dataTree.toNodesByType.get(objectName)) {
                roots.add(new BrowseNode(node));
            }
            leaves = roots;
        } catch (Exception e) {
            LOGGER.error('Error in init: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Attach child nodes from objectName to the leaf
    * @author Tushar Walse | 23-09-2024 
    * @param leaf Leaf node to attach children to
    * @param objectName Name of the object to retrieve children from
    **/
    public void setChildNodes(BrowseNode leaf, String objectName) {
        try {
            if(objectName.startsWith('<')) {
                setBackNode(leaf, objectName);
                return;
            }        
            backLevel = null;
            leaf.childNodes.put(currentLevel, new BrowseNode[]{});
            leaf.lastLevel = currentLevel;
            for(ICS_CTRL_GetDataTree.Node node : leaf.dataNode.getLinkedNodes(objectName)) {
                leaf.childNodes.get(currentLevel).add(new BrowseNode(node, currentLevel, leaf));
            }
        } catch (Exception e) {
            LOGGER.error('Error attaching next level child nodes in setChildNodes: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Create new child node with reference to previous parent
    * @author Tushar Walse | 23-09-2024 
    * @param leaf Parent node to attach child node to
    * @param objectName The name of the child object
    **/
    public void setBackNode(BrowseNode leaf, String objectName) {
        try {
            leaf.childNodes.put(currentLevel, new BrowseNode[]{});
            leaf.lastLevel = currentLevel;
            
            BrowseNode backNode = leaf.parentNode.get(backLevel);
            backNode.parentNode.put(currentLevel, leaf);
            backNode.lastLevel = currentLevel;
            leaf.childNodes.get(currentLevel).add(backNode);
        } catch (Exception e) {
            LOGGER.error('Error creating {0} record node in setBackNode: {1}', new Object[]{objectName, e.getMessage()});
        }
    }

    /**
    * @description Retrieve child objects from leaves
    * @author Tushar Walse | 23-09-2024 
    * @param objectName Child object name to retrieve
    **/
    public void browseChild(String objectName) {
        try {
            currentLevel++;
            if(objectName.startsWith('<')) {
                backLevel = backLevel == null ? currentLevel - 1 : backLevel - 1;
            }
            BrowseNode[] nextLevelLeaves = new BrowseNode[]{};
            for(BrowseNode leaf : leaves) {
                setChildNodes(leaf, objectName);
                nextLevelLeaves.addAll(leaf.childNodes.get(currentLevel));
            }
            leaves = nextLevelLeaves;
        } catch (Exception e) {
            LOGGER.error('Error retrieving next level child objects in browseChild: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Check if this is the first object to be retrieved and process
    * @author Tushar Walse | 23-09-2024 
    * @param objectName Object to be retrieved
    **/
    public void browse(String objectName) {
        if(roots == null) {
            init(objectName);
        } else {
            browseChild(objectName);
        }
    }

    /**
    * @description Get all records after processing the query
    * @author Tushar Walse | 23-09-2024 
    * @return SObject[] Records that are result of the query processed
    **/
    public SObject[] getRecords() {
        try {
            SObject[] result = new SObject[]{};
            for(BrowseNode leaf : leaves) {
                result.add(leaf.dataNode.record);
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error retrieving records while processing the query in getRecords: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }
}