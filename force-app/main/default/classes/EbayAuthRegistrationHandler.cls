global class EbayAuthRegistrationHandler implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData userData){
        User u = new User();

        return u;
    }
    global void updateUser(Id userId, Id portalId, Auth.UserData userData){

    }
}