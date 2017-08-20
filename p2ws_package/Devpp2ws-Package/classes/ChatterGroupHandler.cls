/**
 * 	08-Feb-2017 : Sarun Wi.
 *
 *  		Description : to Create Chatter Group and auto Add member init
 *  					 - Name of Each Group should be unique because each group can not relate to record.
 *  					  	I think it's should be like : Flight XXX01 - Group
 *
 */
public class ChatterGroupHandler {

	/**
	 * [createGroupWithMember description to Create Group by Name ]
	 * @param  groupName [Chatter Group Name]
	 * @param  groupType [Type of Group , choose one - public , private, Unlisted ] ** From the requirement, should use Private
	 * @param  listUsers     [List Of Member in this Group (Type must be User )]
	 * @return           [GroupId ]
	 */
	public static CollaborationGroup createGroupWithMembers(String groupName, List<User> listUsers, String groupType) {

		CollaborationGroup thisGroup = new CollaborationGroup(Name = groupName, CollaborationType = groupType);
		thisGroup.OwnerId = UserInfo.getUserId();
		insert thisGroup;

		List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();
		for (User user : listUsers) {
			CollaborationGroupMember member = new CollaborationGroupMember(
			    MemberId = user.Id,
			    CollaborationGroupId = thisGroup.Id,
			    CollaborationRole = getGroupRole(user)
			);
			groupMembers.add(member);
		}
		Database.insert(groupMembers,false);
		return thisGroup;
	}

	public static List<CollaborationGroup> createGroupsWithMembers(Map<String, List<User>> mapGroupNameWithMember,String groupType ){
		List<CollaborationGroup> newGroupForInsert = new List<CollaborationGroup>();

		List<CollaborationGroup> existGroups = [SELECT Id, Name, CollaborationType FROM CollaborationGroup WHERE Name IN :mapGroupNameWithMember.keySet()];
		Map<String, CollaborationGroup> groupMap = new Map<String, CollaborationGroup>();
		for(CollaborationGroup existGroup : existGroups) {
			groupMap.put(existGroup.Name, existGroup);
		}

		for(String groupKey :mapGroupNameWithMember.keySet() ) {
			CollaborationGroup eachGroup;
			if(groupMap.containsKey(groupKey)) {
				eachGroup = groupMap.get(groupKey);
			} else {
				eachGroup = new CollaborationGroup( Name = groupKey, CollaborationType = groupType);
				newGroupForInsert.add(eachGroup);
				groupMap.put(groupKey, eachGroup);
			}
		}

		if(newGroupForInsert != null && !newGroupForInsert.isEmpty()) {
			insert newGroupForInsert;
		}

		List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();
		for(String groupKey :mapGroupNameWithMember.keySet()){
			List<User> users = mapGroupNameWithMember.get(groupKey);
			//AppLogger.debug('ChatterGroupHandler', 'createGroupsWithMembers', groupKey, users.size() + ' ' + JSON.serialize(users), null);
			for (User user : users) {
				CollaborationGroupMember member = new CollaborationGroupMember(
				    MemberId = user.Id,
				    CollaborationGroupId = groupMap.get(groupKey).Id,
				    CollaborationRole = getGroupRole(user)
				);
				groupMembers.add(member);
			}
		}
		Database.insert(groupMembers,false);
		return groupMap.values();
	}
	public static Map<String,Object> addMemberToGroup(String groupName, List<User> listUsers) {
		Map<String,Object> functionResult = new Map<String, Object>();
		List<CollaborationGroup> listGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName ];
		if (!listGroup.isEmpty()) {
			// has Group
			List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();
			CollaborationGroup thisGroup = listGroup.get(0);
			for (User eachUser : listUsers) {
				groupMembers.add(new CollaborationGroupMember(
				                     MemberId = eachUser.Id,
				                     CollaborationGroupId = thisGroup.Id,
				                     CollaborationRole = getGroupRole(eachUser)
				                 ) 	
				                );
			}
			// I assume that If insert not pass, it's should be because It's duplicate with existing Crew, so Im just gonna ignored it 
			functionResult.put('result',Database.insert(groupMembers,false) );
		}
		return functionResult;
	}

	public static void addMemberToGroup(Map<String, List<User>> usermap){
		System.debug('JK: usermap - ' + JSON.serialize(usermap));
		List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();
		Map<String, SObject> groupMap = BE8_GlobalUtility.getSObjectMap('Name', [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :usermap.keySet()]);
		System.debug('JK: groupMap - ' + JSON.serialize(groupMap));
		for(String groupName : usermap.keySet()){
			for(User user : usermap.get(groupName)){
				groupMembers.add(new CollaborationGroupMember(
                     MemberId = user.Id,
                     CollaborationGroupId = ((CollaborationGroup)groupMap.get(groupName)).Id,
                     CollaborationRole = getGroupRole(user)
                 ) 	
                );
			}
		}
		Database.SaveResult[] result = Database.insert(groupMembers, false);
		System.debug('---ADD GROUP RESULT---');
		System.debug(JSON.serialize(result));
	}

	public static Map<String,Object> removeMemberFromGroup(String groupName, List<User> listUsers){
		Map<String,Object> functionResult = new Map<String,Object>();
		List<CollaborationGroup> listGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName ];
		if (!listGroup.isEmpty()) {
			Set<Id> setUserId = new Set<Id>();
			for(User eachUser :listUsers){
				setUserId.add(eachUser.Id);
			}
			CollaborationGroup thisGroup = listGroup.get(0);
			List<CollaborationGroupMember> removeGroupMember = [Select Id From CollaborationGroupMember Where CollaborationGroupId =:thisGroup.Id and MemberId in:setUserId  ];
			if(!removeGroupMember.isEmpty()){
				try{
					delete removeGroupMember;
					functionResult.put('isSuccess',true);
				}catch(DmlException ex){
					functionResult.put('isSuccess',false);
					functionResult.put('errorMsg',ex.getMessage());
				}
			}else{
				functionResult.put('isSuccess',true);
				functionResult.put('warningMsg','There is no Member of this list of User in this Group');
			}
		}else{
			functionResult.put('isSuccess',true);
			functionResult.put('warningMsg','not found group');
		}
		return functionResult;
	}
	public static String getGroupRole(User eachUser) {
		// some criteria to choose between 'Standard' or 'Admin'
		return 'Standard';
	}
}