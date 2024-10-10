@isTest
private class SyncProductResponseDtoTest { // ProductSyncResponseDtoTest
    @isTest
    static void testJsonDeserializationCombined() {
        Product2 product1 = new Product2(
            Name = 'Robotic Arm Assembly System',
            Stock__c = 10,
            Description = 'Robotic Arm Assembly System',
            IsActive = true,
            ProductCode = '1234',
            Family = 'Robotics'
        );
        
        Product2 product2 = new Product2(
            Name = 'Wheeled Assembly',
            Stock__c = 5,
            Description = 'Wheeled Assembly',
            IsActive = false,
            ProductCode = '5678',
            Family = 'Assemblies'
        );

        insert new List<Product2>{product1, product2};

        String jsonString = '{"deletedProductIds":["' + product1.Id + '", "' + product2.Id + '"],"updatedProducts":[{"Id":"' + product1.Id + '","Stock__c":10,"Name":"Robotic Arm Assembly System","Description":"Robotic Arm Assembly System","IsActive":true,"ProductCode":"1234","Family":"Robotics"},{"Id":"' + product2.Id + '","Stock__c":5,"Name":"Wheeled Assembly","Description":"Wheeled Assembly","IsActive":false,"ProductCode":"5678","Family":"Assemblies"}]}';

        SyncProductResponseDto responseDto = (SyncProductResponseDto) JSON.deserialize(jsonString, SyncProductResponseDto.class);

        List<Id> deletedIds = responseDto.deletedProductIds;
        System.assertEquals(2, deletedIds.size(), 'There should be 2 deleted product IDs');
        System.assertEquals(product1.Id, deletedIds[0], 'First deleted product ID should match');
        System.assertEquals(product2.Id, deletedIds[1], 'Second deleted product ID should match');

        List<Product2> updatedProducts = responseDto.updatedProducts;
        System.assertEquals(2, updatedProducts.size(), 'There should be 2 updated products');

        Product2 productReceived1 = updatedProducts[0];
        System.assertEquals(product1.Id, productReceived1.Id, 'First updated product ID should match');
        System.assertEquals(10, productReceived1.Stock__c, 'Stock__c for first product should be 10');
        System.assertEquals('Robotic Arm Assembly System', productReceived1.Name, 'Name should match for first product');
        System.assertEquals('Robotic Arm Assembly System', productReceived1.Description, 'Description should match for first product');
        System.assertEquals(true, productReceived1.IsActive, 'IsActive for first product should be true');
        System.assertEquals('1234', productReceived1.ProductCode, 'ProductCode should match for first product');
        System.assertEquals('Robotics', productReceived1.Family, 'Family should match for first product');

        Product2 productReceived2 = updatedProducts[1];
        System.assertEquals(product2.Id, productReceived2.Id, 'Second updated product ID should match');
        System.assertEquals(5, productReceived2.Stock__c, 'Stock__c for second product should be 5');
        System.assertEquals('Wheeled Assembly', productReceived2.Name, 'Name should match for second product');
        System.assertEquals('Wheeled Assembly', productReceived2.Description, 'Description should match for second product');
        System.assertEquals(false, productReceived2.IsActive, 'IsActive for second product should be false');
        System.assertEquals('5678', productReceived2.ProductCode, 'ProductCode should match for second product');
        System.assertEquals('Assemblies', productReceived2.Family, 'Family should match for second product');
    }
}