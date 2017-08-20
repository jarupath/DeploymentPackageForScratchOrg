/**
 *  08-Feb-2017 : Sarun Wi.
 *              Description : to manage data of flight to create Flight Chatter Group
 *
 */
public class FlightChatterGroupHandler {
    public FlightChatterGroupHandler() {

    }
    public static void createChatterGroupByFlights(List<Flight__c> listScopeFlight) {
        Set<Id> setScopeFlightId = new Set<Id>();
        List<String> setFlightName = new List<String>();
        for (Flight__c eachFlight : listScopeFlight) {
            setScopeFlightId.add(eachFlight.Id);
        }
        Map<String , List<Crew_List__c>> mapCrewListByFlightId = new Map<String, List<Crew_List__c> >();
        List<Crew_List__c> listCrewMember = getListRelatedCrewByFlightId(setScopeFlightId);
        List<Crew__c> listCrewData = new List<Crew__c>();
        System.debug('List Crew Member :' + listCrewMember);
        for (Crew_List__c crewMember : listCrewMember ) {
            listCrewData.add(new Crew__c(Id = crewMember.CrewId__c ));
            if (mapCrewListByFlightId.containsKey(crewMember.FlightId__c)) {
                List<Crew_List__c> listExistingCrewMember =  mapCrewListByFlightId.get(crewMember.FlightId__c);
                listExistingCrewMember.add(crewMember);
                mapCrewListByFlightId.put(crewMember.FlightId__c, listExistingCrewMember);
            } else {
                mapCrewListByFlightId.put(crewMember.FlightId__c, new List<Crew_List__c> {crewMember});
            }
        }

        Map<Id, User> mapUserByCrewId = setUpCrewMemberToUser(listCrewData);

        Map<String, List<User>> mapScopeCrewByName = new Map<String, List<User>>();

        List<User> listChatterAdminUser = getListChatterAdminUser();
        for (Flight__c flight : listScopeFlight) {
            String groupname = flight.Name + '_' + flight.Leg_Number__c;
            System.debug(mapCrewListByFlightId);
            LIst<Crew_List__c> listExistingCrew = mapCrewListByFlightId.get(flight.Id);
            List<User> listFlightUser = new List<User>();
            if (listExistingCrew != null && !listExistingCrew.isEmpty()) {
                for (Crew_List__c crewMember : listExistingCrew) {
                    if (mapUserByCrewId.containsKey(crewMember.CrewId__c)) {
                        listFlightUser.add(mapUserByCrewId.get(crewMember.CrewId__c) );
                        if (!listChatterAdminUser.isEmpty()) {
                            listFlightUser.addAll(listChatterAdminUser);
                        }
                    }
                }
            }
            mapScopeCrewByName.put(groupname, listFlightUser);
        }

        List<CollaborationGroup> listGroup = ChatterGroupHandler.createGroupsWithMembers(mapScopeCrewByName, 'Private');
        System.debug(listGroup);
    }

    // basiclly this function transform from listCrew to Map of User by Crew Id
    // Which I gonna use it to map between Crew Member and User.
    public static Map<Id, User> setUpCrewMemberToUser(List<Crew__c> listCrew) {
        Map<Id, User> mapCrewUser = new Map<Id, User>();
        if (!listCrew.isEmpty()) {
            Set<Id> setCrewId = new Set<Id>();
            for (Crew__c thisCrew : listCrew) {
                setCrewId.add(thisCrew.Id);
            }
            Map<Id, Crew_Mapping__c> mapCrewMapping;
            if (!setCrewId.isEmpty()) {
                CrewHandler.setMapCrewMappingByCrewId(setCrewId);
                mapCrewMapping = CrewHandler.getMapCrewMappingByCrewId();
            }
            Set<Id> setUserId = new Set<Id>();
            for (Crew__c thisCrew : listCrew) {
                Crew_Mapping__c thisCrewMapping = mapCrewMapping.get(thisCrew.Id);
                if (thisCrewMapping != null) {
                    if (thisCrewMapping.UserId__c != null) {
                        setUserId.add(thisCrewMapping.UserId__c);
                    }
                }
            }
            if (!setUserId.isEmpty()) {
                mapCrewUser = new Map<Id, User>();
                Map<Id, User> mapUserId = getListCrewUser(setUserId);
                for (Crew__c thisCrew : listCrew) {
                    if (mapCrewMapping.containsKey(thisCrew.Id)) {
                        Crew_Mapping__c thisCrewMapping = mapCrewMapping.get(thisCrew.Id);
                        if (thisCrewMapping.UserId__c != null) {
                            mapCrewUser.put(thisCrew.Id, mapUserId.get(thisCrewMapping.UserId__c) );
                        }
                    }

                }
            }
        } else {
            // this mean there is no crew on this flight
        }
        return mapCrewUser;
    }

    public static List<Crew_List__c> getListRelatedCrewByFlightId(Set<Id> setFlightId) {
        return [Select Id,
                Name ,
                CrewId__c,
                OwnerId,
                FlightId__c
                From Crew_List__c
                Where FlightId__c in:setFlightId ];
    }
    public static Map<Id , User> getListCrewUser(Set<Id> setUserId) {
        return new Map<Id, User>([Select Id, Name , ProfileId, Profile.Name, UserRoleId, UserRole.Name From User Where Id in:setUserId ]);
    }
    public static List<User> getListAdminUser() {
        return [Select Id, Name , ProfileId, Profile.Name, UserRoleId, UserRole.Name From User Where Profile.Name = 'System Administrator' ];
    }
    public static List<User> getListChatterAdminUser() {
        List<User_List__mdt> userList = [SELECT DeveloperName, Username__c FROM User_List__mdt WHERE DeveloperName = 'ChatterAdmin'];
        if (!userList.isEmpty()) {
            Set<String> usernameSet = new Set<String>();
            for (User_List__mdt eachUserList : userList) {
                usernameSet.addAll(eachUserList.Username__c.Split(','));
            }
            return [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name FROM User WHERE Username IN :usernameSet];
        }
        return new List<User>();
    }


    public static List<User> getListGroundUser() {
        return [Select Id, Name , ProfileId, Profile.Name, UserRoleId, UserRole.Name From User ];
    }
    public static List<User> getListUserByCriteria(Set<String> setSomeCriteria) {
        return [Select Id, Name , ProfileId, Profile.Name, UserRoleId, UserRole.Name From User ];
    }
}