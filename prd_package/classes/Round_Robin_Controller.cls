public without sharing class Round_Robin_Controller {

    private static Map<id, list<Case_Member__c>> Mapgroupwithmember;
    private static list<Case_Member__c> listgroupmember;

    static {
        getgroupmember(); //Query and put value to Mapgroupwithmember.
        System.debug('### Map Group with Member : ' + Mapgroupwithmember);
    }


public static void roundrobin_method(list<case> listcase) {

        Map<Case_Member__c, Case_Member__c> mapmemberrecieve = new Map<Case_Member__c, Case_Member__c>();
        Set<Case_Member__c> listfirstmember = new Set<Case_Member__c>();

        for (Case thiscase : listcase) {
            id ownerresultid = thiscase.ownerid;
            Boolean firstroundrobin = true;

            System.debug('### Case Owner id : ' + thiscase.ownerid);

            if (Mapgroupwithmember.ContainsKey(thiscase.ownerid)) {
                list<Case_Member__c> listmember = Mapgroupwithmember.get(thiscase.ownerid);
                Integer i = 0;

                System.debug('### list member size : ' + listmember.size());

                if (listmember.size() > 0) {
                    for (Case_Member__c mb : listmember) {
                        if (mb.Assigned__c) {

                            Case_Member__c lastmember = mb;
                            Case_Member__c thismember = listmember[0];

                            System.debug('### lastmember : ' + mb.Userid__r.name);
                            System.debug('### thismember : ' + listmember[0].Userid__r.name);
                            System.debug('### current i : ' + i);

                            if (i == (listmember.size() - 1))
                                thismember = listmember[0];
                            else
                                thismember = listmember[i + 1];

                            thiscase.ownerid = thismember.userid__c;
                            System.debug('### ownerresultid : ' + ownerresultid);
                            mapmemberrecieve.put(thismember, lastmember);

                            firstroundrobin = false;

                            break;
                        }

                        i++;
                    }

                    if (firstroundrobin) {
                        thiscase.ownerid = listmember[0].userid__c;
                        listfirstmember.add(listmember[0]);
                    }
                }

            }

            System.debug('### Map not containskey : ');
        }

        if (mapmemberrecieve.size() > 0) {
            Markmemberrecieved(mapmemberrecieve);
        }

        if (listfirstmember.size() > 0) {
            Markfirstmemberrecieved(listfirstmember);
        }


        System.debug('### Map size member : ' + mapmemberrecieve.size() + ' ### list size first member : ' + listfirstmember.size());
    }

    public static void roundrobin_method(list<case> listcase, Map<Id, User> roleMap, Map<Id, Case> oldCaseMap) {

        Map<Case_Member__c, Case_Member__c> mapmemberrecieve = new Map<Case_Member__c, Case_Member__c>();
        Set<Case_Member__c> listfirstmember = new Set<Case_Member__c>();

        for (Case thiscase : listcase) {
            id ownerresultid = thiscase.ownerid;
            Boolean firstroundrobin = true;

            System.debug('### Case Owner id : ' + thiscase.ownerid);

            if (Mapgroupwithmember.ContainsKey(thiscase.ownerid)) {
                list<Case_Member__c> listmember = Mapgroupwithmember.get(thiscase.ownerid);
                Integer i = 0;

                System.debug('### list member size : ' + listmember.size());

                if (listmember.size() > 0) {
                    for (Case_Member__c mb : listmember) {
                        if (mb.Assigned__c) {

                            Case_Member__c lastmember = mb;
                            Case_Member__c thismember = listmember[0];

                            System.debug('### lastmember : ' + mb.Userid__r.name);
                            System.debug('### thismember : ' + listmember[0].Userid__r.name);
                            System.debug('### current i : ' + i);

                            if (i == (listmember.size() - 1))
                                thismember = listmember[0];
                            else
                                thismember = listmember[i + 1];

                            thiscase.ownerid = thismember.userid__c;
                            System.debug('### ownerresultid : ' + ownerresultid);
                            mapmemberrecieve.put(thismember, lastmember);

                            firstroundrobin = false;
                            //Case_Management.updateCaseOnEscalatedStatus(thiscase, roleMap, oldCaseMap);

                            break;
                        }

                        i++;
                    }

                    if (firstroundrobin) {
                        thiscase.ownerid = listmember[0].userid__c;
                        listfirstmember.add(listmember[0]);
                        //Case_Management.updateCaseOnEscalatedStatus(thiscase, roleMap, oldCaseMap);
                    }
                }
            }

            System.debug('### Map not containskey : ');
        }

        if (mapmemberrecieve.size() > 0) {
            Markmemberrecieved(mapmemberrecieve);
        }

        if (listfirstmember.size() > 0) {
            Markfirstmemberrecieved(listfirstmember);
        }


        System.debug('### Map size member : ' + mapmemberrecieve.size() + ' ### list size first member : ' + listfirstmember.size());
    }

    private static void Markmemberrecieved(Map<Case_Member__c, Case_Member__c> mapmemberrecieve) {
        List<Case_Member__c> caseMemberListForUpdate = new List<Case_Member__c>();
        for (Case_Member__c thismember : mapmemberrecieve.Keyset()) {
            if (mapmemberrecieve.Containskey(thismember)) {
                Case_Member__c lastmember = mapmemberrecieve.get(thismember);
                thismember.Assigned__c = true;
                thismember.Last_Assigned_Time__c = System.now();
                lastmember.Assigned__c = false;
                caseMemberListForUpdate.add(thismember);
                caseMemberListForUpdate.add(lastmember);
            }
        }
        if(!caseMemberListForUpdate.isEmpty()) {
            //Edit By JK
            Set<Case_Member__c> caseMemberSetForUpdate = new Set<Case_Member__c>(caseMemberListForUpdate);
            update new List<Case_Member__c>(caseMemberSetForUpdate);
            //
            //update caseMemberListForUpdate;
        }
    }

    private static void Markfirstmemberrecieved(Set<Case_Member__c> listfirstmember) {

        List<Case_Member__c> listthismember = new List<Case_Member__c>();

        //This method for mark current assigned member and clear previous assigned member.
        for (Case_Member__c thismember : listfirstmember) {

            thismember.Assigned__c = true;
            thismember.Last_Assigned_Time__c = System.now();
            listthismember.add(thismember);
        }

        update listthismember;
    }

    private static void getgroupmember() {
        Mapgroupwithmember = new Map<id, list<Case_Member__c>>();

        if (listgroupmember == null) {
            listgroupmember = [Select id, name, assigned__c, Last_Assigned_Time__c, Case_Teamid__c, Userid__r.Isactive,
                               Round_Robin_Status__c, Userid__c, Userid__r.name, Type__c, Tier__c, Email__c, Queueid__c
                               from Case_Member__c
                               where Type__c = 'Round Robin User' and Case_Teamid__r.active__c = true and Userid__r.Isactive = true 
                                               order by id ASC];
        }

        if (listgroupmember.size() > 0) {
            for (Case_Member__c gm : listgroupmember) {
                list<Case_Member__c> listnewmember = new list<Case_Member__c>();
                if (Mapgroupwithmember.ContainsKey(gm.Queueid__c)) {
                    listnewmember = Mapgroupwithmember.get(gm.Queueid__c);
                    listnewmember.add(gm);
                    Mapgroupwithmember.put(gm.Queueid__c, listnewmember);
                } else {
                    listnewmember.add(gm);
                    Mapgroupwithmember.put(gm.Queueid__c, listnewmember);
                }
            }

        }
    }

}