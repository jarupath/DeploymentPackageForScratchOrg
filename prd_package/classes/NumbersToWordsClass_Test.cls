@isTest
private class NumbersToWordsClass_Test
{
	@isTest
	static void testTenThoudsandConvert() {
		Assert.assertEquals('Eighty Eight Thousand', new NumbersToWordsClass().convert(88000), 'Test for "NumberToWordsClass"');
		NumbersToWordsClass convertClass = new NumbersToWordsClass();
		convertClass.numberval = 88000;
		Assert.assertEquals('Eighty Eight Thousand', convertClass.convert(), '"Test for convertClass.concert()"');
		Assert.assertEquals('Eighty Eight Thousand', convertClass.wordText, '"Test for convertClass.wordText"');
		//Assert.assertEquals('Nine  Billion Ninety Nine  Billion Nine  Hundred  Ninety Nine  Million Nine  Hundred  Ninety Nine  Thousand Nine  Hundred  Ninety Nine', convertClass.convert(Long.valueOf('999999999999')));
	}

	@isTest
	static void testUnitConvert(){
		Assert.assertEquals('Nine', new NumbersToWordsClass().convert(9), 'Test for "NumberToWordsClass"');
		NumbersToWordsClass convertClass = new NumbersToWordsClass();
		convertClass.numberval = 9;
		Assert.assertEquals('Nine', convertClass.convert(), '"Test for convertClass.concert()"');
		Assert.assertEquals('Nine', convertClass.wordText, '"Test for convertClass.wordText"');
	}

	@isTest
	static void testTenConvert(){
		Assert.assertEquals('Ninety Nine', new NumbersToWordsClass().convert(99), 'Test for "NumberToWordsClass"');
		NumbersToWordsClass convertClass = new NumbersToWordsClass();
		convertClass.numberval = 99;
		Assert.assertEquals('Ninety Nine', convertClass.convert(), '"Test for convertClass.concert()"');
		Assert.assertEquals('Ninety Nine', convertClass.wordText, '"Test for convertClass.wordText"');
	}

	@isTest
	static void testHundredConvert(){
		Assert.assertEquals('Nine Hundred Ninety Nine', new NumbersToWordsClass().convert(999), 'Test for "NumberToWordsClass"');
		NumbersToWordsClass convertClass = new NumbersToWordsClass();
		convertClass.numberval = 999;
		Assert.assertEquals('Nine Hundred Ninety Nine', convertClass.convert(), '"Test for convertClass.concert()"');
		Assert.assertEquals('Nine Hundred Ninety Nine', convertClass.wordText, '"Test for convertClass.wordText"');
	}
}