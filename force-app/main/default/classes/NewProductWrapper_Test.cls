@isTest
public class NewProductWrapper_Test {

      @isTest
    static void testProductItemsCreation() {
        NewProductWrapper.ProductItems productItem = new NewProductWrapper.ProductItems();
        productItem.isDisplay = true;
        productItem.maxItems = 10;
        productItem.minItems = 1;
        productItem.minValue = 1;
        productItem.itemType = 'Test';
        productItem.maxValue = 10;        
        productItem.description = 'Description';
        productItem.required = true;
        productItem.status = 'Active';
        productItem.isChildCollection = false;
        productItem.name = 'Name';
        productItem.sectionId = 'SecID';
        productItem.parentItemId = 'ParentId1';
        productItem.productItemId = 'ItemId2';
        productItem.productId = 'Prod1';
        productItem.productItemKey = 'Test Key';
        List<string>  itemTypes = new List<string>();
        itemTypes.add('Item1');
		productItem.requiredItemTypes = itemTypes;
        System.assertEquals(true, productItem.isDisplay, 'isDisplay should be true.');
        System.assertEquals(10, productItem.maxItems, 'maxItems should be 10.');
    }

    @isTest
    static void testChildItemsCreation() {
        NewProductWrapper.ChildItems childItem = new NewProductWrapper.ChildItems();
        childItem.status = 'Active';
        childItem.minItems = 1;
        childItem.maxItems = 10;
        childItem.minValue = 1;
        childItem.itemType = 'Test';
        childItem.maxValue = 10;      
        childItem.isDisplay = true;
        childItem.description = 'Description';
        childItem.required = true;
        childItem.isChildCollection = false;
        childItem.name = 'Surname';
        childItem.sectionId = 'SecID';
        childItem.parentItemId = 'ParentId1';
        childItem.productItemId = 'ItemId2';
        childItem.productId = 'Prod1';
        childItem.productItemKey = 'Test Key';
		List<string>  childItems = new List<string>();
        childItems.add('childItemss');
        childItem.requiredItemTypes = childItems;
        System.assertEquals('Active', childItem.status, 'Status should be Active.');
        System.assertEquals(1, childItem.minItems, 'minItems should be 1.');
    }

    @isTest
    static void testItemPropertiesCreation() {
        NewProductWrapper.ItemProperties itemProperty = new NewProductWrapper.ItemProperties();
        itemProperty.name = 'Surname';
        itemProperty.valueType = 'String';
        itemProperty.validator = 'Str1';
        itemProperty.validatorType = 'Test';
        itemProperty.isRatingFactor = true;    
        itemProperty.lookUpValue = 'Test';
        itemProperty.description = 'Description';
        itemProperty.required = true;
        itemProperty.default_g = 'Active';
        itemProperty.isLookup = false;
        itemProperty.lookupName = 'SecID';
        itemProperty.controlType = 'ParentId1';
        itemProperty.productItemId = 'ItemId2';
        
        System.assertEquals('Surname', itemProperty.name, 'Name should be Surname.');
        System.assertEquals('String', itemProperty.valueType, 'valueType should be String.');
    }
}