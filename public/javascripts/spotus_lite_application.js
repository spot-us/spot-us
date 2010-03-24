function resizeIframe()
{
	$("#spotus_lite").height( WindowHeight() - getObjHeight(document.getElementById("toolbar")) );
}

function WindowHeight()
{
	var de = document.documentElement;
	return self.innerHeight ||
		(de &amp;amp;amp;&amp;amp;amp; de.clientHeight ) ||
		document.body.clientHeight;
}

function getObjHeight(obj)
{
	if( obj.offsetWidth )
	{
		return obj.offsetHeight;
	}
	return obj.clientHeight;
}

resizeIframe();