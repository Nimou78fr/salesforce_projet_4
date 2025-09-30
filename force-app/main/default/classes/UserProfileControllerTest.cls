@isTest
private class UserProfileControllerTest {

    @isTest
    static void testGetUserProfileName() {
        Test.startTest();
        String profileName = UserProfileController.getUserProfileName();
        Test.stopTest();

        System.assertNotEquals(null, profileName);
        System.assert(profileName.length() > 0);
    }
}
