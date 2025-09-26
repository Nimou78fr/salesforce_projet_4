public with sharing class UserProfileController {
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName() {
        // Récupérer le nom du profil de l'utilisateur connecté , ex: "Standard User", "System Administrator"//
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
}