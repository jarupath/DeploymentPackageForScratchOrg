public with sharing class BatchManager {
	public String flightNumber {get; set;}
	public String flightDate {get; set;}
	public List<AsyncApexJob> jobList {get{
			return [SELECT Id, ApexClass.Name, Status, CreatedDate FROM AsyncApexJob WHERE Status NOT IN ('Completed', 'Failed') AND ApexClass.Name = 'PreFlightBatch' AND CreatedDate = TODAY ORDER BY CreatedDate LIMIT 100];
		} set;
	}

	public PageReference runBatch() {
		try {
			if (flightNumber != null && flightDate != null) {
				Database.executeBatch(new PreFlightBatch('', flightNumber, Date.valueOf(flightDate), 'UTC'));
			}
		} catch (Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}
		return null;
	}

	public PageReference runFlightBatch1() {
		List<String> flightNumberList = new List<String> {'TG0603', 'TG0637', 'TG0644', 'TG0647', 'TG0648', 'TG0650', 'TG0651', 'TG0661', 'TG0662', 'TG0673', 'TG0675', 'TG0687', 'TG0910', 'TG0924', 'TG0930', 'TG0249', 'TG0250', 'TG0251', 'TG0252', 'TG0281', 'TG0282', 'TG0287', 'TG0672', 'TG0674', 'TG0676', 'TG0677', 'TG0678', 'TG0679', 'TG0682', 'TG0944', 'TG0950', 'TG0954', 'TG0960', 'TG0970', 'TG0102', 'TG0103', 'TG0104', 'TG0105', 'TG0110', 'TG0111', 'TG0116', 'TG0117', 'TG0120', 'TG0121', 'TG0288', 'TG0301', 'TG0302', 'TG0303', 'TG0304', 'TG0305', 'TG0306', 'TG0307', 'TG0313', 'TG0315', 'TG0317', 'TG0686', 'TG0911', 'TG0916', 'TG0917', 'TG0683', 'TG0201', 'TG0202', 'TG0203', 'TG0204', 'TG0207', 'TG0319', 'TG0320', 'TG0321', 'TG0322', 'TG0323', 'TG0318', 'TG0920', 'TG0921', 'TG0925', 'TG0926', 'TG0926', 'TG0324', 'TG0325', 'TG0329', 'TG0331', 'TG0337', 'TG0341', 'TG0342', 'TG0927', 'TG0931', 'TG0945', 'TG0951', 'TG0952', 'TG0953', 'TG0350', 'TG0401', 'TG0402', 'TG0403', 'TG0404', 'TG0407', 'TG0408', 'TG0409', 'TG0410', 'TG0349', 'TG0955'};
		runPreconfiguredFlightBatch(flightNumberList);
		return null;
	}

	public PageReference runFlightBatch2() {

		List<String> flightNumberList = new List<String> {'TG0961', 'TG0971', 'TG0414', 'TG0415', 'TG0416', 'TG0417', 'TG0413', 'TG0431', 'TG0432', 'TG0433', 'TG0434', 'TG0435', 'TG0436', 'TG0418', 'TG0461', 'TG0466', 'TG0472', 'TG0474', 'TG0475', 'TG0481', 'TG0482', 'TG0491', 'TG0492', 'TG0517', 'TG0518', 'TG0550', 'TG0551', 'TG0556', 'TG0557', 'TG0560', 'TG0561', 'TG0564', 'TG0565', 'TG0570', 'TG0571', 'TG0574', 'TG0575', 'TG0580', 'TG0581', 'TG0584', 'TG0585', 'TG0600', 'TG0601', 'TG0602', 'TG0606', 'TG0607', 'TG0608', 'TG0609', 'TG0612', 'TG0613', 'TG0614', 'TG0615', 'TG0618', 'TG0619', 'TG0620', 'TG0621', 'TG0622', 'TG0623', 'TG0624', 'TG0625', 'TG0628', 'TG0628', 'TG0629', 'TG0629', 'TG0208', 'TG0634', 'TG0634', 'TG0635', 'TG0635', 'TG0636', 'TG0638', 'TG0639', 'TG0212', 'TG0215', 'TG0216', 'TG0217', 'TG0218', 'TG0211', 'TG0219', 'TG0640', 'TG0641', 'TG0642', 'TG0643', 'TG0645', 'TG0646', 'TG0649', 'TG0656', 'TG0657', 'TG0658', 'TG0308', 'TG0314', 'TG0316', 'TG0326', 'TG0330', 'TG0332', 'TG0338', 'TG0340', 'TG0352', 'TG0462', 'TG0465'};
		runPreconfiguredFlightBatch(flightNumberList);
		return null;
	}

	public PageReference runFlightBatch3() {
		List<String> flightNumberList = new List<String> {'TG0473', 'TG0476', 'TG0220', 'TG0221', 'TG0222', 'TG0225', 'TG0226', 'TG0241', 'TG0242', 'TG0659', 'TG0660', 'TG0663', 'TG0664', 'TG0665', 'TG0668', 'TG0669', 'TG0670', 'TG0671', 'TG0963'};
		runPreconfiguredFlightBatch(flightNumberList);
		return null;
	}

	private void runPreconfiguredFlightBatch(List<String> flightNumberList) {
		try {
			Date day = null;
			if (flightDate == null) {
				day = Date.today();
			} else {
				day = Date.valueOf(flightDate);
			}
			for (String flightNumber : flightNumberList) {
				Database.executeBatch(new PreFlightBatch('', flightNumber, day, 'LT'));
			}
		} catch (Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}
	}
}