<!-- upload.jsp -->
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="java.util.*,java.io.File,java.lang.Exception,
java.io.*,java.net.*,javax.imageio.ImageIO, java.awt.image.*" %>

<h1>Data Received at the Server</h1>

<hr />

<strong>Uploaded File[s] Info:</strong>

<%

String optionalFileName = "";

FileItem fileItem = null;

String dirName = application.getRealPath("/");
String thumbName = dirName+"thumbs/";
String eqThumbName = dirName+"eqThumbs/";
String canThumbName = dirName+"canThumbs/";
String uploadName = dirName+"uploads/";
String equalizeName = dirName+"equalize/";
String cannyName = dirName+"canny/";
String eqJobs = dirName+"eqJobs/";
String canJobs = dirName+"canJobs/";
String tagsFolder = dirName+"tags/";

int i=0;

if (ServletFileUpload.isMultipartContent(request)) {

	ServletFileUpload servletFileUpload = 
			new ServletFileUpload(new DiskFileItemFactory());
	List fileItemsList = servletFileUpload.parseRequest(request);
	Iterator it = fileItemsList.iterator();

	while (it.hasNext()) {
		FileItem fileItemTemp = (FileItem)it.next();

		if (fileItemTemp.isFormField()) {

		%>
		<strong>Name-value Pair Info:</strong>
		Field name: <%= fileItemTemp.getFieldName() %>
		Field value: <%= fileItemTemp.getString() %>
		<%

			if (fileItemTemp.getFieldName().equals("filename"))
				optionalFileName = fileItemTemp.getString();

		}

		else fileItem = fileItemTemp;

		if (fileItem!=null) {
			String fileName = fileItem.getName();
			if (fileName.length() <= 0) {
				%>
				<b>Uploaded File Info:</b><br/>
				You must select a file first.
				<br/>
				<br/>
				<form action="pictureUpload.jsp">
				<input type="submit" value="Go Back" />
				</form>
				<%
				return;
			}
			else if (fileName.length() <= 4) {
				%>
				<b>Uploaded File Info:</b><br/>
				File must have file extension in name.
				<br/>
				<br/>
				<form action="pictureUpload.jsp">
				<input type="submit" value="Go Back" />
				</form>
				<%
				return;
			}
			String fileType = fileName.substring(fileName.length()-4);
			fileType.toLowerCase();
			if (!(fileType.equals(".png") || fileType.equals(".jpg") ||
					fileType.equals("tiff") || fileType.equals("jpeg"))) {
				%>
				<b>Uploaded File Info:</b><br/>
				Not a compatible file.
				<br/>
				<br/>
				<form action="pictureUpload.jsp">
				<input type="submit" value="Go Back" />
				</form>
				<%
				return;
			}
			
			%>
			<b>Uploaded File Info:</b><br/>
			Content type: <%= fileItem.getContentType() %><br/>
			Field name: <%= fileItem.getFieldName() %><br/>
			File name: <%= fileName %><br/>
			File size: <%= fileItem.getSize() %><br/><br/>
			File name: <font color="blue"> <%= fileName %></font>
			File size: <font color="blue"> 
			<%= fileItem.getSize() %> Bytes</font>
			<%

			if (fileItem.getSize() > 0) {
	
				if (optionalFileName.trim().equals(""))
					fileName = FilenameUtils.getName(fileName);
	
				else fileName = optionalFileName;
				
				String finalDirName = uploadName;
				String finalThumbName = thumbName;
				if (fileItem.getFieldName().equals("equalize picture")) {
					finalDirName = equalizeName;
					finalThumbName = eqThumbName;
					File del = new File(eqJobs+fileName);
					if(del.exists()) del.delete();
				}
				else if (fileItem.getFieldName().equals("canny picture")) {
					finalDirName = cannyName;
					finalThumbName = canThumbName;
					File del = new File(canJobs+fileName);
					if(del.exists()) del.delete();
				}
				
				File saveTo = new File(finalDirName + fileName);

				try {
					fileItem.write(saveTo);
					%>
					Upload Status: <font color="blue">Uploaded successfully</font>
					<br />
					
					Image: <br />
					<img src="uploads/<%=fileName%>" alt="" name=<%=fileName%> id="" />
					<br />
					Enter Tags Here:
					<br />
					<form method="post" action="processing.jsp">
					<textarea readonly name="tagname" cols="40" rows="1"><%=fileName%></textarea><br>
					Tags: <br>
					<textarea name="tags" cols="40" rows="5"><% 
					File f = new File(tagsFolder+fileName);
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
					
					<%
					
					BufferedImage thumb = new BufferedImage(100, 100, BufferedImage.TYPE_INT_RGB);
					BufferedImage uploadedImg = ImageIO.read(saveTo);
					thumb.createGraphics().drawImage(uploadedImg.getScaledInstance
							(100, 100, BufferedImage.SCALE_SMOOTH),0,0,null);
					ImageIO.write(thumb, "jpg", new File(finalThumbName + fileName));
				} catch (Exception e) {
					%>
					Error: <font color="red">An error occurred while 
					saving the uploaded file.</font>
					<%=e%>
					<%
				}

			}
			
			else {
				%>
				Error: <font color="red">File size below 0 Bytes.</font>
				<%
				return;
			}
		}
	}
}

%>
<br/>
<br/>
<form action="pictureUpload.jsp">
<input type="submit" value="Go Back" />
</form>