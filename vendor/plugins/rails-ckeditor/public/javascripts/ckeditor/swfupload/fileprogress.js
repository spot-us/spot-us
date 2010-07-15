/* ******************************************
 *	FileProgress Object
 *	Control object for displaying file info
 * ****************************************** */

var FileThumb = new Class({
    initialize: function(element){
      this.element = $(element);
      this.init();
    },
    
    init: function(){
      this.element.getElements('div.FCKThumb').addEvents({
          'mouseover': function(){
              this.addClass('FCKSelectedBox');
          },
          'mouseout': function(){
              this.removeClass('FCKSelectedBox');
          },
          'click': function(){
              image = this.getElement('img.image');
              setUrl(image.alt);
          }
      });

    }
});

var ToolBar = new Class({
    initialize: function(element){
      this.container = $(element);
      this.buttons = new Array();
      
      this.table = null;
    },
    
    clear: function(){
      this.buttons = new Array();
    },
    
    init: function(){
      this.table = document.createElement('table');
      this.table.appendChild(document.createElement("TBODY"));
      this.table.border = 0;
      this.table.setAttribute('cellspacing', 0);
      this.table.setAttribute('cellpadding', 0);
      this.table.className = "TB_Toolbar";
      
      var row = this.table.tBodies[0].insertRow(0);
      var cell = row.insertCell(row.cells.length);
      
      div = document.createElement('div');
      div.className = 'TB_Start';
      div.innerHTML = "&nbsp;"
      cell.appendChild(div);
      
      this.init_buttons(row);
      
      this.container.appendChild(this.table);
    },
    
    init_buttons: function(row){
      
      for(var i = 0; i < this.buttons.length; i++)
      {
        var cell = row.insertCell(row.cells.length);  
        this.buttons[i].init();
        cell.appendChild(this.buttons[i].element);
      }
      
    }
    
});

var Button = new Class({
  initialize: function(title, text, image){
    this.title = title;
    this.text = text;
    this.image = image;
    
    this.callback = function(){};
    this.element = null;
  },
  
  init: function(){
    this.element = document.createElement('div');
    this.element.title = this.title;
    this.element.className = "TB_Button";
    
    table = document.createElement('table');
    table.appendChild(document.createElement("TBODY"));
    table.border = 0;
    table.setAttribute('cellspacing', 0);
    table.setAttribute('cellpadding', 0);
    
    var row = table.tBodies[0].insertRow(0);
    var cell = row.insertCell(row.cells.length);
    
    image = document.createElement('img');
    image.src = '/javascripts/ckeditor/images/' + this.image;
    image.className = 'TB_Button_Image';
    
    cell.appendChild(image);
    
    var cell = row.insertCell(row.cells.length);
    cell.className = 'TB_Button_Text';
    cell.innerHTML = this.text;
    row.appendChild(cell);
    
    var cell = row.insertCell(row.cells.length);
    image = document.createElement('img');
    image.src = '/javascripts/ckeditor/images/spacer.gif';
    image.className = 'TB_Button_Padding';
    cell.appendChild(image);
    
    this.element.appendChild(table);
    
    this.element.addEvents({
          'mouseover': function(){
              this.className = "TB_Button_Off_Over"
          },
          'mouseout': function(){
              this.className = "TB_Button"
          },
          'click': this.callback.bind(this)
    });
  }
});

function FileProgress(file, targetID) {
	this.fileProgressID = "divFileProgress";

	this.fileProgressWrapper = document.getElementById(this.fileProgressID);
	if (!this.fileProgressWrapper) {
		this.fileProgressWrapper = document.createElement("div");
		this.fileProgressWrapper.className = "progressWrapper";
		this.fileProgressWrapper.id = this.fileProgressID;

		this.fileProgressElement = document.createElement("div");
		this.fileProgressElement.className = "progressContainer";

		var progressCancel = document.createElement("a");
		progressCancel.className = "progressCancel";
		progressCancel.href = "#";
		progressCancel.style.visibility = "hidden";
		progressCancel.appendChild(document.createTextNode(" "));

		var progressText = document.createElement("div");
		progressText.className = "progressName";
		progressText.appendChild(document.createTextNode(file.name));

		var progressBar = document.createElement("div");
		progressBar.className = "progressBarInProgress";

		var progressStatus = document.createElement("div");
		progressStatus.className = "progressBarStatus";
		progressStatus.innerHTML = "&nbsp;";

		this.fileProgressElement.appendChild(progressCancel);
		this.fileProgressElement.appendChild(progressText);
		this.fileProgressElement.appendChild(progressStatus);
		this.fileProgressElement.appendChild(progressBar);

		this.fileProgressWrapper.appendChild(this.fileProgressElement);

		document.getElementById(targetID).appendChild(this.fileProgressWrapper);
		//fadeIn(this.fileProgressWrapper, 0);

	} else {
		this.fileProgressElement = this.fileProgressWrapper.firstChild;
		this.fileProgressElement.childNodes[1].firstChild.nodeValue = file.name;
	}

	this.height = this.fileProgressWrapper.offsetHeight;

}
FileProgress.prototype.setProgress = function (percentage) {
	this.fileProgressElement.className = "progressContainer green";
	this.fileProgressElement.childNodes[3].className = "progressBarInProgress";
	this.fileProgressElement.childNodes[3].style.width = percentage + "%";
};
FileProgress.prototype.setComplete = function () {
	this.fileProgressElement.className = "progressContainer blue";
	this.fileProgressElement.childNodes[3].className = "progressBarComplete";
	this.fileProgressElement.childNodes[3].style.width = "";

};
FileProgress.prototype.setError = function () {
	this.fileProgressElement.className = "progressContainer red";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

};
FileProgress.prototype.setCancelled = function () {
	this.fileProgressElement.className = "progressContainer";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

};
FileProgress.prototype.setStatus = function (status) {
	this.fileProgressElement.childNodes[2].innerHTML = status;
};

FileProgress.prototype.toggleCancel = function (show, swfuploadInstance) {
	this.fileProgressElement.childNodes[0].style.visibility = show ? "visible" : "hidden";
	if (swfuploadInstance) {
		var fileID = this.fileProgressID;
		this.fileProgressElement.childNodes[0].onclick = function () {
			swfuploadInstance.cancelUpload(fileID);
			return false;
		};
	}
};
