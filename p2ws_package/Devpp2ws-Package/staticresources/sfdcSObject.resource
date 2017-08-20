function SFDCSObject(type) {
	this.attributes = {"type" : type};

	this.addChild = function(field, childObject) {
		console.log(this[field]);
		if(this[field] == undefined) {
			this[field] = {};
		}
		console.log(this[field].records);
		if(this[field].records == undefined) {
			this[field].records = [];
		}
		this[field].records.push(childObject);
		this[field].totalSize = this[field].records.length;
	};
		
	this.addChilds = function(field, childObjects) {
		for (var i = 0; i<childObjects.length; i++) {
			this.addChild(field, type, childObjects[i]);
		}
	};

	this.addValue =function(field, value) {
		this[field] = value;
		return this;
	};

	this.getJSON = function() {
		return JSON.stringify(this);
	}
}

console.log('load SFDCSObject');