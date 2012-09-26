<!-- processing.jsp -->
<%@ page import="java.util.*,java.io.File,java.lang.Exception,
java.io.*,java.net.*" %>

<h1>Processing: </h1><br>

<%
String root = application.getRealPath("/");
String eqJobs = root + "eqJobs/";
String canJobs = root + "canJobs/";
String tagsFolder = root + "tags/";
Socket socket = null;
PrintWriter outSocket = null;
BufferedReader inSocket = null;
int character;
int PORTNNUM = 8675;
String backendServerDomainName = "";

	try{
		String equalize = request.getParameter("equalize");
		String canny = request.getParameter("canny");
		String tags = request.getParameter("tags");

		String name = "ERROR";
		File f;
		
		if (tags != null) {
			
			if (tags.trim().length() == 0) {
		    %>
		      	You did not input any tags!
		    <%
		    } else {
		    %>
				Tags are: <br><%=tags%>
				<%
				name = request.getParameter("tagname");
				f = new File(tagsFolder+name);
				if(!f.exists()){
					f.createNewFile();
				}
				FileOutputStream outfile = new FileOutputStream(f);
				outfile.write(tags.getBytes());
				outfile.close();
		    }
		    %>
			<br/>
			<br/>
			<form action="pictureUpload.jsp">
			<input type="submit" value="Go Back" />
			</form>
			<%
			return;
		}
		
		try{
		    socket = new Socket("localhost", PORTNUM);
		}
		catch(java.net.ConnectException e){
			try{
			    socket = new Socket(backendServerDomainName, PORTNUM);
			}
			catch(java.net.ConnectException ex){
			%>
			    You must first start the server application at the command prompt.
			    <br/>
				<br/>
				<form action="pictureUpload.jsp">
				<input type="submit" value="Go Back" />
				</form>
			<%
				return;
			}
		}
		
		outSocket = new PrintWriter(socket.getOutputStream(), true);
	    inSocket = new BufferedReader (new 
	            InputStreamReader(socket.getInputStream()));
		
		if (equalize == null && canny == null) { 
		%>
			You must select something.
			<br/>
			<br/>
			<form action="pictureUpload.jsp">
			<input type="submit" value="Go Back" />
			</form>
		<%
			socket.close();
			return;
		}
		
		if (equalize != null) {
			name = equalize;
			f = new File(eqJobs+name);
			if(!f.exists()){
				f.createNewFile();
			}
			%>
			Histogram Equalization: <%=name%><br>
			<%
			
			outSocket.println("e"+name+"\n");
		}
		else outSocket.println("N\n");
		
		if (canny != null) {
			name = canny;
			f = new File(canJobs+name);
			if(!f.exists()){
				f.createNewFile();
			}
			%>
			Canny Edge Detection: <%=name%><br>
			<%
			outSocket.println("c"+name+"\n");
		}
		else outSocket.println("N\n");
		%>
		<br>
		<%
		while ((character = inSocket.read()) != -1) {
		    out.print((char) character);
		    if ((char) character == '\n') {
		    	%>
		    	<br>
		    	<%
		    }
		    	
		}
		
		socket.close();
	}
	catch(IOException e) {
		socket.close();
	}

%>
<br/>
<br/>
<form action="pictureUpload.jsp">
<input type="submit" value="Go Back" />
</form>
