<html>
<head>
<title>File Uploading Form</title>
<style type="text/css"><!--
  #container { position: relative; }
  #canvas { border: 1px solid #000; }
  #imageTemp { position: absolute; top: 1px; left: 1px; }
--></style>
</head>
<body>
<h3>File Upload:</h3>

<%@ page import="java.util.*,java.io.File,java.lang.Exception,
java.io.*,java.net.*" %>

Select a file to upload: <br />
<form action="upload.jsp" method="post"
                        enctype="multipart/form-data">
<input type="file" name="upload picture" size="50" />
<br />
<input type="submit" value="Upload File" />
</form>

<h1>Pictures</h1>
<%
String root = application.getRealPath("/");
String uploads = root + "uploads/";
String equalize = root + "equalize/";
String canny = root + "canny/";
String eqJobs = root + "eqJobs/";
String canJobs = root + "canJobs/";
String tagsFolder = root + "tags/";

java.io.File file;
java.io.File dir = new java.io.File(uploads);
java.io.File eqDir = new java.io.File(equalize);
java.io.File canDir = new java.io.File(canny);
java.io.File eqJobsDir = new java.io.File(eqJobs);
java.io.File canJobsDir = new java.io.File(canJobs);
 
String[] list = dir.list();
String[] eqList = eqDir.list();
String[] eqJobsList = eqJobsDir.list();
String[] canList = canDir.list();
String[] canJobsList = canJobsDir.list();

for (int i = 0; i < list.length; i++) {
	boolean isEq = false;
	boolean isCan = false;
	for (int j = 0; j < eqList.length; j++) {
		if (list[i].equals(eqList[j])) {
			isEq = true;
			break;
		}
	}
	for (int j = 0; j < canList.length; j++) {
		if (list[i].equals(canList[j])) {
			isCan = true;
			break;
		}
	}
	file = new java.io.File(uploads + list[i]);
	if (!file.isDirectory()) {
	%>
	<table border="1">
	
	<tr>
	<td>
	<a href="uploads/<%=list[i]%>">
	<img src="thumbs/<%=list[i]%>" alt="" name=<%=list[i]%> width="100" height="100" id="" />
	</a>
	</td>
	<%
	if (isEq == true) { 
	%>
	<td>
	<a href="equalize/<%=list[i]%>" target="_top">
	<img src="eqThumbs/<%=list[i]%>" alt="" name=<%=list[i]%> width="100" height="100" id="" /><br>
	</a>
	</td>
	<%
	} 
	if (isCan == true) {
	%>
	<td>
	<a href="canny/<%=list[i]%>" target="_top">
	<img src="canThumbs/<%=list[i]%>" alt="" name="<%=list[i]%>" width="100" height="100" id="" /> <br>
	</a>
	</td>
	<%
	} 
	%>
	</tr>

	<tr>
	<td> <a href="uploads/<%=list[i]%>"><%=list[i]%></a></td>
	<%
	if (isEq == true) { 
	%>
	<td><a href="equalize/<%=list[i]%>" target="_top"><%=list[i]%>(equalized)</a></td>
	<%
	} 
	if (isCan == true) {
	%>
	<td><a href="canny/<%=list[i]%>" target="_top"><%=list[i]%>(canny)</a></td>
	<%
	} 
	%>
	</tr>
	<tr>
	<td colspan="3">
	<form action="processing.jsp" method="POST">
		<input type="checkbox" name="equalize" value=<%=list[i]%> /> 
		Histogram Equalization
		<input type="checkbox" name="canny" value=<%=list[i]%>  /> 
		Canny Edge Detection 
		<input type="submit" value="Select Processing" />
	</form>
	</td>
	</tr>
	<tr><td colspan="3">
	<form method="post" action="processing.jsp">
	<textarea readonly name="tagname" cols="40" rows="1"><%=list[i]%></textarea><br>
	Tags: <br>
	<textarea name="tags" cols="40" rows="5"><% 
	File f = new File(tagsFolder+list[i]);
	if (f.exists()) {
		StringBuffer fileData = new StringBuffer(1000);
		BufferedReader reader = new BufferedReader(new FileReader(f));
		char[] buf = new char[1024];
		int numRead=0;
		while((numRead=reader.read(buf)) != -1){
		String readData = String.valueOf(buf, 0, numRead);
		fileData.append(readData);
		buf = new char[1024];
		}
		reader.close();
		%><%=fileData.toString()%><%
	}
	%></textarea><br>
	<input type="submit" value="Submit" />
	</form>
	</td></tr>
	</table>
	<br><br>
	<%
	}
}
%>

<h1>Jobs</h1>
<ul>
<%
for (int i = 0; i < eqJobsList.length; i++) {
	file = new java.io.File(eqJobs + eqJobsList[i]);
	if (!file.isDirectory()) {
	%>
	<li><%=eqJobsList[i]%>(Histogram Equalization)<br>
	<%
	}
}
%>

<%
for (int i = 0; i < canJobsList.length; i++) {
	file = new java.io.File(canJobs + canJobsList[i]);
	if (!file.isDirectory()) {
	%>
	<li><%=canJobsList[i]%>(Canny Edge Detection)<br>
	<%
	}
}
%>
</ul>

</body>
</html>
