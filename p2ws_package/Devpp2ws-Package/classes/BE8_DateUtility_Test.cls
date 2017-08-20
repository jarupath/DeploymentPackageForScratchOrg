/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description: Test Class Common Date Utility.

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/09/2016  Charnun.T          First Create
------------------------------------------------------------*/
@isTest
private class BE8_DateUtility_Test {
    static testMethod void testToCleanDateFormat() {
        Assert.assertEquals('02/12/2016', BE8_DateUtility.toCleanDateFormat('12/2/2016'), 'Expected valid date');
        Assert.assertEquals('02/04/2016', BE8_DateUtility.toCleanDateFormat(' 4/2/2016 '), 'Expected valid date');
    }
    static testMethod void testIsValidDate_DDMMYYYY() {
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '12/2/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '2/02/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '02/02/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '   02/12/2016   '), 'Expected valid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '02/02/2016/'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '31/31/2016'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '31-2-2016'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_DDMMYYYY, '31.2.2016'), 'Expected invalid date');

    }
    static testMethod void testIsValidDate_MMDDYYYY() {
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '2/12/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '2/2/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '02/02/2016'), 'Expected valid date');
        Assert.assertEquals(true, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '   2/12/2016   '), 'Expected valid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '02/02/2016/'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '31/2/2016'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '31-2-2016'), 'Expected invalid date');
        Assert.assertEquals(false, BE8_DateUtility.isValidDate(BE8_DateUtility.FORMAT_MMDDYYYY, '31.2.2016'), 'Expected invalid date');
    }
    static testMethod void testToDate() {
        String regex_DDMMYYYY = '^([1-9]|[123]0|[012][1-9]|31)/([1-9]|0[1-9]|1[012])/(19[0-9]{2}|2[0-9]{3})$' ;
        String regex_MMDDYYYY =  '^([1-9]|0[1-9]|1[012])/([1-9]|[123]0|[012][1-9]|31)/(19[0-9]{2}|2[0-9]{3})$' ;

        Date date1 = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_MMDDYYYY, '2/12/2016');
        Date date2 = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMYYYY, '30/3/2016');
        Date date3 = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMYYYY, '12/2/2016');
        Date date4 = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '12FEB16');
        Date date5 = BE8_DateUtility.toDateGregorian(BE8_DateUtility.FORMAT_MMDDYYYY, '12/02/2016');
        Date date6 = BE8_DateUtility.toDateGregorian(BE8_DateUtility.FORMAT_DDMMYYYY, '12/02/2016');

        // 19/9/16 Validate by returning date instead
        Assert.assertNotEquals(null, date1, 'Expected valid date');
        Assert.assertNotEquals(null, date2, 'Expected valid date');
        Assert.assertNotEquals(null, date3, 'Expected valid date');
        Assert.assertNotEquals(null, date4, 'Expected valid date');
        Assert.assertNotEquals(null, date5, 'Expected valid date');
        Assert.assertNotEquals(null, date6, 'Expected valid date');
    }
    static testMethod void testConvertToTGFlightDateformat() {
        Assert.assertEquals('01JAN16', BE8_DateUtility.convertToTGFlightDateformat('2016-01-01', '-'));
        Assert.assertEquals('01FEB16', BE8_DateUtility.convertToTGFlightDateformat('2016-02-01', '-'));
        Assert.assertEquals('01MAR16', BE8_DateUtility.convertToTGFlightDateformat('2016-03-01', '-'));
        Assert.assertEquals('01APR16', BE8_DateUtility.convertToTGFlightDateformat('2016-04-01', '-'));
        Assert.assertEquals('01MAY16', BE8_DateUtility.convertToTGFlightDateformat('2016-05-01', '-'));
        Assert.assertEquals('01JUN16', BE8_DateUtility.convertToTGFlightDateformat('2016-06-01', '-'));
        Assert.assertEquals('01JUL16', BE8_DateUtility.convertToTGFlightDateformat('2016-07-01', '-'));
        Assert.assertEquals('01AUG16', BE8_DateUtility.convertToTGFlightDateformat('2016-08-01', '-'));
        Assert.assertEquals('01SEP16', BE8_DateUtility.convertToTGFlightDateformat('2016-09-01', '-'));
        Assert.assertEquals('01OCT16', BE8_DateUtility.convertToTGFlightDateformat('2016-10-01', '-'));
        Assert.assertEquals('01NOV16', BE8_DateUtility.convertToTGFlightDateformat('2016-11-01', '-'));
        Assert.assertEquals('01DEC16', BE8_DateUtility.convertToTGFlightDateformat('2016-12-01', '-'));
    }
    static testMethod void testGetStrDateExcludeSeparater() {
        Assert.assertEquals('20161201', BE8_DateUtility.getStrDateExcludeSeparater('2016-12-01', '-'));
    }

    static testMethod void testConvertBirthDate() {
        Assert.assertEquals('1978-07-15', BE8_DateUtility.convertBirthDate('15JUL78'));
        //Assert.assertEquals('1917-07-15', BE8_DateUtility.convertBirthDate('15JUL17'));
        Assert.assertEquals('2016-07-15', BE8_DateUtility.convertBirthDate('15JUL16'));
        Assert.assertEquals('2015-07-15', BE8_DateUtility.convertBirthDate('15JUL15'));
        Assert.assertEquals('2014-07-15', BE8_DateUtility.convertBirthDate('15JUL14'));
    }

    static testMethod void testGetBirthDate() {
        // Normal case
        Date date1 = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_MMDDYYYY, '07/15/1978');
        Assert.assertEquals(date1, BE8_DateUtility.getBirthDate('15JUL78'));

        // Pax age is 99
        DateTime currentDateTime = DateTime.now();
        String strCurrentYearPlus1 = '' + (currentDateTime.year() + 1); // If current year is 2017, plus 1 is 2018
        String strCurrentYearPlus1_2Digits = strCurrentYearPlus1.substring(strCurrentYearPlus1.length() - 2, strCurrentYearPlus1.length()); // If current year + 1 is 2018, 2 digits is 18
        String strBirthYear = '' + (currentDateTime.year() + 1 - 100); // If current year is 2017, birth year is 1918
        Assert.assertEquals(BE8_DateUtility.toDate('YYYY-MM-DD', strBirthYear + '-07-15'), BE8_DateUtility.getBirthDate('15JUL' + strCurrentYearPlus1_2Digits)); // if current year is 2017, strBirthYear = 1918-07-15
    }

    static testMethod void testToUpperMonthValueShouldReturnDateWithUpperCaseMonthValue() {
        Assert.assertEquals('01JAN16', BE8_DateUtility.toUpperMonthValue('01Jan16'));
        Assert.assertEquals('01FEB16', BE8_DateUtility.toUpperMonthValue('01Feb16'));
        Assert.assertEquals('01MAR16', BE8_DateUtility.toUpperMonthValue('01Mar16'));
        Assert.assertEquals('01APR16', BE8_DateUtility.toUpperMonthValue('01Apr16'));
        Assert.assertEquals('01MAY16', BE8_DateUtility.toUpperMonthValue('01May16'));
        Assert.assertEquals('01JUN16', BE8_DateUtility.toUpperMonthValue('01Jun16'));
        Assert.assertEquals('01JUL16', BE8_DateUtility.toUpperMonthValue('01Jul16'));
        Assert.assertEquals('01AUG16', BE8_DateUtility.toUpperMonthValue('01Aug16'));
        Assert.assertEquals('01SEP16', BE8_DateUtility.toUpperMonthValue('01Sep16'));
        Assert.assertEquals('01OCT16', BE8_DateUtility.toUpperMonthValue('01Oct16'));
        Assert.assertEquals('01NOV16', BE8_DateUtility.toUpperMonthValue('01Nov16'));
        Assert.assertEquals('01DEC16', BE8_DateUtility.toUpperMonthValue('01Dec16'));
    }

    static testMethod void testConvertToTGFlightDateTimeformatShouldReturnProperDateTimeValueFormat() {
        Assert.assertEquals('2016-01-01 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('01Jan16 0101'));
        Assert.assertEquals('2016-02-02 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('02Feb16 0101'));
        Assert.assertEquals('2016-03-03 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('03Mar16 0101'));
        Assert.assertEquals('2016-04-04 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('04Apr16 0101'));
        Assert.assertEquals('2016-05-05 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('05May16 0101'));
        Assert.assertEquals('2016-06-06 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('06Jun16 0101'));
        Assert.assertEquals('2016-07-07 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('07Jul16 0101'));
        Assert.assertEquals('2016-08-08 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('08Aug16 0101'));
        Assert.assertEquals('2016-09-09 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('09Sep16 0101'));
        Assert.assertEquals('2016-10-10 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('10Oct16 0101'));
        Assert.assertEquals('2016-11-11 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('11Nov16 0101'));
        Assert.assertEquals('2016-12-12 01:01:00', BE8_DateUtility.convertTGFlightDateTimeformat('12Dec16 0101'));
    }

    static testMethod void testConvertTGFlightTimeformatShouldReturnProperTimeFormat() {
        Assert.assertEquals('01:01:00', BE8_DateUtility.convertTGFlightTimeformat('0101'));
    }

    static testMethod void testConvertToTGFlightDateformatShouldReturnDDMMMYYFormat() {
        Assert.assertEquals('01JAN16', BE8_DateUtility.convertToTGFlightDateformat('2016-01-01', '-'));
        Assert.assertEquals('01FEB16', BE8_DateUtility.convertToTGFlightDateformat('2016-02-01', '-'));
        Assert.assertEquals('01MAR16', BE8_DateUtility.convertToTGFlightDateformat('2016-03-01', '-'));
        Assert.assertEquals('01APR16', BE8_DateUtility.convertToTGFlightDateformat('2016-04-01', '-'));
        Assert.assertEquals('01MAY16', BE8_DateUtility.convertToTGFlightDateformat('2016-05-01', '-'));
        Assert.assertEquals('01JUN16', BE8_DateUtility.convertToTGFlightDateformat('2016-06-01', '-'));
        Assert.assertEquals('01JUL16', BE8_DateUtility.convertToTGFlightDateformat('2016-07-01', '-'));
        Assert.assertEquals('01AUG16', BE8_DateUtility.convertToTGFlightDateformat('2016-08-01', '-'));
        Assert.assertEquals('01SEP16', BE8_DateUtility.convertToTGFlightDateformat('2016-09-01', '-'));
        Assert.assertEquals('01OCT16', BE8_DateUtility.convertToTGFlightDateformat('2016-10-01', '-'));
        Assert.assertEquals('01NOV16', BE8_DateUtility.convertToTGFlightDateformat('2016-11-01', '-'));
        Assert.assertEquals('01DEC16', BE8_DateUtility.convertToTGFlightDateformat('2016-12-01', '-'));
    }

    static testMethod void testConvertMonthValue() {
        Assert.assertEquals('01', BE8_DateUtility.convertMonthValue('Jan'));
        Assert.assertEquals('02', BE8_DateUtility.convertMonthValue('Feb'));
        Assert.assertEquals('03', BE8_DateUtility.convertMonthValue('Mar'));
        Assert.assertEquals('04', BE8_DateUtility.convertMonthValue('Apr'));
        Assert.assertEquals('05', BE8_DateUtility.convertMonthValue('May'));
        Assert.assertEquals('06', BE8_DateUtility.convertMonthValue('Jun'));
        Assert.assertEquals('07', BE8_DateUtility.convertMonthValue('Jul'));
        Assert.assertEquals('08', BE8_DateUtility.convertMonthValue('Aug'));
        Assert.assertEquals('09', BE8_DateUtility.convertMonthValue('Sep'));
        Assert.assertEquals('10', BE8_DateUtility.convertMonthValue('Oct'));
        Assert.assertEquals('11', BE8_DateUtility.convertMonthValue('Nov'));
        Assert.assertEquals('12', BE8_DateUtility.convertMonthValue('Dec'));

        Assert.assertEquals('01', BE8_DateUtility.convertMonthValue('JAN'));
        Assert.assertEquals('02', BE8_DateUtility.convertMonthValue('FEB'));
        Assert.assertEquals('03', BE8_DateUtility.convertMonthValue('MAR'));
        Assert.assertEquals('04', BE8_DateUtility.convertMonthValue('APR'));
        Assert.assertEquals('05', BE8_DateUtility.convertMonthValue('MAY'));
        Assert.assertEquals('06', BE8_DateUtility.convertMonthValue('JUN'));
        Assert.assertEquals('07', BE8_DateUtility.convertMonthValue('JUL'));
        Assert.assertEquals('08', BE8_DateUtility.convertMonthValue('AUG'));
        Assert.assertEquals('09', BE8_DateUtility.convertMonthValue('SEP'));
        Assert.assertEquals('10', BE8_DateUtility.convertMonthValue('OCT'));
        Assert.assertEquals('11', BE8_DateUtility.convertMonthValue('NOV'));
        Assert.assertEquals('12', BE8_DateUtility.convertMonthValue('DEC'));
    }

    static testMethod void testConvertMonthNumber() {
        Assert.assertEquals('JAN', BE8_DateUtility.convertMonthNumber('01'));
        Assert.assertEquals('FEB', BE8_DateUtility.convertMonthNumber('02'));
        Assert.assertEquals('MAR', BE8_DateUtility.convertMonthNumber('03'));
        Assert.assertEquals('APR', BE8_DateUtility.convertMonthNumber('04'));
        Assert.assertEquals('MAY', BE8_DateUtility.convertMonthNumber('05'));
        Assert.assertEquals('JUN', BE8_DateUtility.convertMonthNumber('06'));
        Assert.assertEquals('JUL', BE8_DateUtility.convertMonthNumber('07'));
        Assert.assertEquals('AUG', BE8_DateUtility.convertMonthNumber('08'));
        Assert.assertEquals('SEP', BE8_DateUtility.convertMonthNumber('09'));
        Assert.assertEquals('OCT', BE8_DateUtility.convertMonthNumber('10'));
        Assert.assertEquals('NOV', BE8_DateUtility.convertMonthNumber('11'));
        Assert.assertEquals('DEC', BE8_DateUtility.convertMonthNumber('12'));
    }

    static testMethod void testConvertTGFlightDateformat() {
        Assert.assertEquals('2015-11-14', BE8_DateUtility.convertTGFlightDateformat('14NOV15', null));
        Assert.assertEquals('2013-12-12', BE8_DateUtility.convertTGFlightDateformat('12/DEC/13', '/'));
    }

    static testMethod void testConvertDateFormatToTraditionalFormat() {
        Assert.assertEquals('14NOV15' , BE8_DateUtility.convertDateFormatToTraditionalFormat('2015-11-14'));
    }

    static testMethod void testGetExactCRONFromDateTime() {
        Assert.assertEquals('2 30 12 1 12 ? 2008', BE8_DateUtility.getExactCRONFromDateTime(Datetime.newInstance(2008, 12, 1, 12, 30, 2)));
    }

    static testMethod void testConvertDateToDateTime() {
        Date d = Date.newInstance(2014, 10, 5);
        Assert.assertEquals(datetime.newInstance(d.year(), d.month(), d.day()), BE8_DateUtility.convertDateToDateTime(d));
    }

    static testMethod void testForMobile(){
        DateTime dt = DateTime.newInstance(2011, 11, 18, 3, 3, 3);
        String dtString = '2011-11-17T20:03:03.000Z';
        String dString = '2011-11-17T17:00:00.000Z';
        Assert.assertEquals(dt, BE8_DateUtility.convertFromStringToDateTimeFromMobile(dtString));
        Assert.assertEquals(dtString, BE8_DateUtility.convertDateTimeToStringForMobileApp(dt));
        Assert.assertEquals(dString, BE8_DateUtility.convertDateToStringForMobileApp(dt.date()));
        Assert.assertEquals(dt.date(), BE8_DateUtility.convertStringToDate('2011-11-18'));
        Assert.assertEquals(dt, BE8_DateUtility.convertStringToDateTime('2011-11-17 20:03:03'));
        Assert.assertEquals('20:03', BE8_DateUtility.convertDateTimeToTimeString(dt));
    }
}