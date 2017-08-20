/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description: Common Date Utility.

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/09/2016  Charnun.T          First Create
------------------------------------------------------------*/
public with sharing class BE8_DateUtility {
    public static String FORMAT_DDMMYYYY = 'dd/MM/yyyy';
    public static String FORMAT_MMDDYYYY = 'MM/dd/yyyy';
    public static String FORMAT_DDMMMYY = 'ddMMMyy';
    public static String FORMAT_YYYYMMDD = 'YYYY-MM-DD';
    public static String FORMAT_IETF = 'EEE, dd MMM yyyy HH:mm:ss Z';
    public static String FORMAT_MOBILE = 'dd/MM/yyyy HH:mm';

    public class DateException extends Exception {}

    // convert dd/MM/yyyy to MM/dd/yyyy
    @TestVisible private static String toCleanDateFormat(String orgDate) {
        if (String.isBlank(orgDate)) return orgDate;
        String [] s = orgDate.trim().split('/');
        String day = '';
        if (s[0].length() == 1) day = '0' + s[0];
        else day = s[0];
        String month = '';
        if (s[1].length() == 1) month = '0' + s[1];
        else month = s[1];
        return month + '/' + day + '/' + s[2];
    }
    public static Boolean isValidDate(String orgFormatting, String orgDate) {
        Boolean isValid = false;
        String newOrgDate = orgDate.deleteWhitespace();

        if (String.isBlank(orgDate)) return false;
        if (FORMAT_DDMMYYYY.equals(orgFormatting)) {
            String regex = '^([1-9]|[123]0|[012][1-9]|31)/([1-9]|0[1-9]|1[012])/(19[0-9]{2}|2[0-9]{3})$' ;
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(newOrgDate);
            if (regexMatcher.matches()) isValid = true;

        }
        if (FORMAT_MMDDYYYY.equals(orgFormatting)) {
            String regex =  '^([1-9]|0[1-9]|1[012])/([1-9]|[123]0|[012][1-9]|31)/(19[0-9]{2}|2[0-9]{3})$' ;
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(newOrgDate);
            if (regexMatcher.matches()) isValid = true;
        }

        return isValid;
    }
    public static Date toDate(String orgFormatting, String orgDate) {
        Date newDate = null;

        if (orgDate == null || orgDate.length() == 0) {
            return null;
        }

        Integer yearOffset = 0;
        if (UserInfo.getLocale() == BE8_GlobalConstants.SFDC_THAI_LOCALE) {
            yearOffset = 543;
        }

        if (FORMAT_MMDDYYYY.equals(orgFormatting)) {
            orgDate = toCleanDateFormat(orgDate);
            String [] s = orgDate.trim().split('/');
            Integer thisYear = Integer.valueOf(s[2]);
            if (thisYear > 2500) thisYear -= 543;
            newDate = Date.newInstance(thisYear, Integer.valueOf(s[1]), Integer.valueOf(s[0])); // year, month, day
        } else if (FORMAT_DDMMYYYY.equals(orgFormatting)) {
            orgDate = toCleanDateFormat(orgDate);
            newDate = toDate(FORMAT_MMDDYYYY, orgDate);
        } else if (FORMAT_YYYYMMDD.equals(orgFormatting)) {
            String[] s = orgDate.trim().split('-');
            Integer thisYear = Integer.valueOf(s[0]);
            if (thisYear > 2500) thisYear -= 543;
            newDate = Date.newInstance(thisYear, Integer.valueOf(s[1]), Integer.valueOf(s[2])); // year, month, day
        } else if (FORMAT_DDMMMYY.equals(orgFormatting)) {
            try {
                String[] s = new String[3];
                s[0] = orgDate.substring(0, 2);
                s[1] = convertMonthValue(orgDate.substring(2, 5));
                s[2] = orgDate.substring(5, 7);
                Integer y = Integer.valueOf(s[2]);
                if (y >= 40) s[2] = '19' + s[2]; else s[2] = '20' + s[2];
                Integer thisYear = Integer.valueOf(s[2]);
                if (thisYear > 2500) thisYear -= 543;
                newDate = Date.newInstance(thisYear, Integer.valueOf(s[1]), Integer.valueOf(s[0]));
            } catch (Exception e) {
                return null;
            }
        }
        return newDate;
    }

    public static Date toDateGregorian(String orgFormatting, String orgDate) {
        Date newDate = null;
        if (FORMAT_MMDDYYYY.equals(orgFormatting)) {
            orgDate = toCleanDateFormat(orgDate);
            String [] s = orgDate.trim().split('/');
            newDate = Date.newInstance(Integer.valueOf(s[2]), Integer.valueOf(s[1]), Integer.valueOf(s[0])); // year, month, day
        } else if (FORMAT_DDMMYYYY.equals(orgFormatting)) {
            orgDate = toCleanDateFormat(orgDate);
            newDate = toDate(FORMAT_MMDDYYYY, orgDate);
        }
        return newDate;
    }

    /*
        Edit by: Jarupath Kulsiriruangyos Latest Updated: 11 Oct 2016
    */

    public static String convertTGFlightDateformat(String inputDate) {
        if (inputDate != null) {
            String day = inputDate.substring(0, 2);
            String month = convertMonthValue(inputDate.substring(2, inputDate.length() - 2));
            String year = '20' + inputDate.substring(inputDate.length() - 2, inputDate.length());
            if (month != null) {
                //System.debug('Date Converted: ' + inputDate);
                return year + '-' + month + '-' + day;
            } else {
                //System.debug('original date format: ' + inputDate);
                return inputDate;
            }
        } else
            return null;

    }

    public static String toUpperMonthValue(String inputDate) {
        if (inputDate != null) {
            String day = inputDate.substring(0, 2);
            String month = inputDate.substring(2, inputDate.length() - 2).toUpperCase();
            String year = inputDate.substring(inputDate.length() - 2, inputDate.length());
            return day + month + year;
        } else
            return null;
    }

    public static String convertTGFlightDateTimeformat(String inputDateTime) {
        if (!String.isBlank(inputDateTime)) {
            String[] datetimesplit = inputDateTime.split(' ');
            if (datetimesplit.size() >= 2) {
                String returnDate = convertTGFlightDateformat(datetimesplit[0]);
                String returntime = convertTGFlightTimeformat(datetimesplit[1]);

                if (returnDate != datetimesplit[0] && returntime != datetimesplit[1]) {
                    //System.debug('Datetime Converted: ' + inputDateTime);
                    return returnDate + ' ' + returntime;
                } else {
                    //System.debug('Original Date Format: ' + inputDateTime);
                    return inputDateTime;
                }
            } else {
                return null;
            }
        } else
            return null;
    }
    public static String convertTGFlightTimeformat(String inputTime) {
        if (!String.isBlank(inputTime)) {
            if (!inputTime.contains(':')) {
                String returntime = inputTime.substring(0, 2) + ':' + inputTime.substring(2, inputTime.length()) + ':00';
                return returntime;
            } else {
                return inputTime;
            }
        } else
            return null;
    }

    public static String convertTGFlightDateformat(String inputDate, String delimeter) {
        if (!String.isBlank(inputDate)) {
            if (!String.isBlank(delimeter)) {
                String[] temp = inputDate.split(delimeter);
                String day = temp[0];
                String month = convertMonthValue(temp[1]);
                String year = '20' + temp[2];
                return year + '-' + month + '-' + day;
            } else {
                String day = inputDate.substring(0, 2);
                String month = convertMonthValue(inputDate.substring(2, inputDate.length() - 2));
                String year = '20' + inputDate.substring(inputDate.length() - 2, inputDate.length());
                return year + '-' + month + '-' + day;
            }
        } else return null;
    }

    public static String convertToTGFlightDateformat(String inputDate, String delimeter) {
        if (!String.isBlank(inputDate)) {
            try {
                if (!String.isBlank(delimeter)) {
                    String[] temp = inputDate.split(delimeter);
                    String year = temp[0].substring(2, temp[0].length());
                    String month = convertMonthNumber(temp[1]);
                    String day = temp[2];
                    return day + month + year;
                } else {
                    String year = inputDate.substring(0, 4);
                    String month = convertMonthNumber(inputDate.substring(4, inputDate.length() - 2));
                    String day = inputDate.substring(inputDate.length() - 2, inputDate.length());
                    return day + month + year;
                }
            } catch (Exception e) {
                String message = '{"inputDate":"' + inputDate + '","delimeter","' + delimeter + '"}';
                AppLogger.error('BE8_DateUtility', 'convertToTGFlightDateformat', inputDate, message, null);
                return null;
            }

        } else return null;
    }

    public static String convertDateFormatToTraditionalFormat(String d) {
        if (!String.isBlank(d)) {
            List<String> datesplit = d.split('-');
            String year = datesplit.get(0).substring(2, datesplit.get(0).length());
            String month = convertMonthNumber(datesplit.get(1));
            String day = datesplit.get(2);
            return day + month + year;
        } else {
            return '';
        }
    }

    public static String convertMonthValue(String month) {
        Map<String, String> convertmap = new Map<String, String>();
        convertmap.put('Jan', '01');
        convertmap.put('Feb', '02');
        convertmap.put('Mar', '03');
        convertmap.put('Apr', '04');
        convertmap.put('May', '05');
        convertmap.put('Jun', '06');
        convertmap.put('Jul', '07');
        convertmap.put('Aug', '08');
        convertmap.put('Sep', '09');
        convertmap.put('Oct', '10');
        convertmap.put('Nov', '11');
        convertmap.put('Dec', '12');

        convertmap.put('JAN', '01');
        convertmap.put('FEB', '02');
        convertmap.put('MAR', '03');
        convertmap.put('APR', '04');
        convertmap.put('MAY', '05');
        convertmap.put('JUN', '06');
        convertmap.put('JUL', '07');
        convertmap.put('AUG', '08');
        convertmap.put('SEP', '09');
        convertmap.put('OCT', '10');
        convertmap.put('NOV', '11');
        convertmap.put('DEC', '12');
        return convertmap.get(month);
    }

    public static String convertMonthNumber(String monthNumber) {
        Map<String, String> convertmap = new Map<String, String>();
        //convertmap.put('01', 'Jan');
        //convertmap.put('02', 'Feb');
        //convertmap.put('03', 'Mar');
        //convertmap.put('04', 'Apr');
        //convertmap.put('05', 'May');
        //convertmap.put('06', 'Jun');
        //convertmap.put('07', 'Jul');
        //convertmap.put('08', 'Aug');
        //convertmap.put('09', 'Sep');
        //convertmap.put('10', 'Oct');
        //convertmap.put('11', 'Nov');
        //convertmap.put('12', 'Dec');

        convertmap.put('01', 'JAN');
        convertmap.put('02', 'FEB');
        convertmap.put('03', 'MAR');
        convertmap.put('04', 'APR');
        convertmap.put('05', 'MAY');
        convertmap.put('06', 'JUN');
        convertmap.put('07', 'JUL');
        convertmap.put('08', 'AUG');
        convertmap.put('09', 'SEP');
        convertmap.put('10', 'OCT');
        convertmap.put('11', 'NOV');
        convertmap.put('12', 'DEC');

        return convertmap.get(monthNumber);
    }

    public static String getExactCRONFromDateTime(DateTime dt) {
        String hour = '' + dt.hour();
        String minute = '' + dt.minute();
        String second = '' + dt.second();
        String day = '' + dt.day();
        String month = '' + dt.month();
        String year = '' + dt.year();
        String cron = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        return cron;
    }

    public static String getStrDateExcludeSeparater(String pStrDate, String pSeparater) {
        if (pStrDate != null) {
            return pStrDate.replaceAll(pSeparater, '');
        }
        return null;
    }

    public static DateTime convertDateToDateTime(Date d) {
        return datetime.newInstance(d.year(), d.month(), d.day());
    }

    public static String convertBirthDate(String pBirthDate) {
        if (pBirthDate == null || pBirthDate.length() != 7) {
            return null;
        }

        String[] s = new String[3];
        s[0] = pBirthDate.substring(0, 2);
        s[1] = BE8_DateUtility.convertMonthValue(pBirthDate.substring(2, 5));
        s[2] = pBirthDate.substring(5, 7);

        Integer day = null;
        Integer month = null;
        Integer year = null;

        try {
            day = Integer.valueOf(s[0]);
        } catch (Exception e) {
            System.debug('ERROR while convertBirthDate - convert day :' + e);
            return null;
        }

        if (s[1] == null) {
            System.debug('ERROR while convertBirthDate - convert month :' + s[1]);
            return null;
        } else {
            month = Integer.valueOf(s[1]);
        }

        try {
            year = Integer.valueOf(s[2]);
            Datetime currentDate = Datetime.now();
            Integer currentYear2Digit = currentDate.year() - 2000;
            //System.debug('Year :' + year + ' - currentYear2Digit :' + currentYear2Digit);
            if (year > currentYear2Digit) {
                year += 1900;
            } else {
                year += 2000;
            }

            if (year > 2500) {
                year -= 543;
            }


        } catch (Exception e) {
            System.debug('ERROR while convertBirthDate - convert year :' + s[2]);
            return null;
        }

        //System.debug('Convert BirthDate, Converting year/month/day :' + year + '/' + month + '/' + day);
        String strYear = '' + year;
        String strMonth = month < 10 ? '0' + month : '' + month;
        String strDay = day < 10 ? '0' + day : '' + day;

        return strYear + '-' + strMonth + '-' + strDay;
    }

    public static Date getBirthDate(String pBirthDate) {
        if (pBirthDate == null || pBirthDate.length() != 7) {
            return null;
        }

        String[] s = new String[3];
        s[0] = pBirthDate.substring(0, 2);
        s[1] = BE8_DateUtility.convertMonthValue(pBirthDate.substring(2, 5));
        s[2] = pBirthDate.substring(5, 7);

        Integer day = null;
        Integer month = null;
        Integer year = null;

        try {
            day = Integer.valueOf(s[0]);
        } catch (Exception e) {
            System.debug('ERROR while getBirthDate - convert day :' + e);
            return null;
        }

        if (s[1] == null) {
            System.debug('ERROR while getBirthDate - convert month :' + s[1]);
            return null;
        } else {
            month = Integer.valueOf(s[1]);
        }

        try {
            year = Integer.valueOf(s[2]);
            Datetime currentDate = Datetime.now();
            Integer currentYear2Digit = currentDate.year() - 2000;
            //System.debug('Year :' + year + ' - currentYear2Digit :' + currentYear2Digit);
            if (year > currentYear2Digit) {
                year += 1900;
            } else {
                year += 2000;
            }
        } catch (Exception e) {
            System.debug('ERROR while getBirthDate - convert year :' + s[2]);
            return null;
        }

        //System.debug('Converting year/month/day :' + year + '/' + month + '/' + day);
        return Date.newInstance(year, month, day);
    }

    public static DateTime convertFromStringToDateTimeFromMobile(String input) {
        if (input != null && !String.isEmpty(input)) {
            input = '"' + input + '"';
            return (DateTime) System.JSON.deserialize(input, DateTime.class);
        } else {
            return null;
        }
    }

    //public static Date convertFromStringToDateFromMobile(String input){
    //    if(input != null && !String.isEmpty(input)){
    //        input = '"' + input + '"';
    //        return (Date) System.JSON.deserialize(input, Date.class);
    //    } else {
    //        return null;
    //    }
    //}

    public static String convertDateTimeToStringForMobileApp(DateTime dt) {
        if (dt != null) {
            return System.JSON.serialize(dt).replace('"', '');
        } else {
            return null;
        }
    }

    public static String convertDateToStringForMobileApp(Date d) {
        if (d != null) {
            DateTime dt = convertDateToDateTime(d);
            return System.JSON.serialize(dt).replace('"', '');
        } else {
            return null;
        }
    }

    public static Date convertStringToDate(String d) {
        if (d != null) {
            return Date.valueOf(d);
        } else {
            return null;
        }
    }

    public static DateTime convertStringToDateTime(String d) {
        if (d != null) {
            return DateTime.valueOfGMT(d);
        } else {
            return null;
        }
    }

    public static String convertDateTimeToTimeString(DateTime dt) {
        if (dt != null) {
            String hour = '' + dt.hourGMT();
            String minute = ('0' + dt.minuteGMT()).right(2);
            return  hour + ':' + minute;
        } return '';
    }
}