package imghadoop.webconnect;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;

public class MargaretWebConnection extends Thread {
	private int port;
	private ServerSocket serverSocket;
	String filename = null;
	String address = null;
	boolean doEq = false, doCan = false;
	Configuration conf = null;
	FileSystem dfs = null;
	ExecutorService executor = null;
	
	public class runJarRun implements Runnable {

		String jar = null;
		String folder = null;
		String filename = null;
		File file = null;
		
		public runJarRun(File file, String jar, String folder, String filename) {
			this.jar = jar;
			this.folder = folder;
			this.filename = filename;
			this.file = file;
		}
		
		@Override
		public void run() {
			try {
				String infolder = folder+filename;
				String outfolder = folder+filename;
				addFile(file, infolder,filename);
				String job = "hadoop jar "+ jar + " " + infolder + " " + outfolder;
				System.out.println("Running command " + job);
				Process proc = Runtime.getRuntime().exec(job);
				proc.waitFor();
				String newName = folder + "/" + filename;
				File newimg = new File(newName);
				readFile(outfolder+"/"+filename, newimg);
				System.out.println(filename + " is done");
				String histAddr = address + "pictureUpload/upload.jsp";
				new MargaretPost(newName, histAddr, folder + " picture");
				//dfs.delete(new Path(infolder),true);
				//dfs.delete(new Path(outfolder),true);
			} catch (Throwable e) {
				e.printStackTrace();
			} 
		}
	
	}
	
	public MargaretWebConnection(int port, String address) {
		this.port = port;
		this.address = address;
		conf = new Configuration();
	    conf.addResource(new Path("/opt/hadoop/conf/core-site.xml"));
	    conf.addResource(new Path("/opt/hadoop/conf/hdfs-site.xml"));
	    try {
			dfs = FileSystem.get(conf);
		} catch (IOException e) {
			e.printStackTrace();
		}
	    
	    executor = Executors.newFixedThreadPool(100);
	}
	
	public void addFile(File source, String folder, String dest) throws Exception{

		Path dir = new Path(folder);
		if (dfs.exists(dir)) {
			dfs.delete(dir, true);
		}
		// Check if the file already exists
		String addr = folder + "/" + dest;
	    Path path = new Path(addr);
	    if (dfs.exists(path)) {
	        System.out.println("File " + addr + " already exists");
	        return;
	    }

	    // Create a new file and write data to it.
	    FSDataOutputStream out = dfs.create(path);
	    InputStream in = new BufferedInputStream(new FileInputStream(source));

	    byte[] b = new byte[1024];
	    int numBytes = 0;
	    while ((numBytes = in.read(b)) > 0) {
	        out.write(b, 0, numBytes);
	    }

	    // Close all the file descripters
	    in.close();
	    out.close();
	}
	
	public void readFile(String source, File dest) throws Exception {

		System.out.println("Reading file " + source);
	    Path path = new Path(source);
	    if (!dfs.exists(path)) {
	        System.out.println(source + " does not exist");
	        return;
	    }

	    FSDataInputStream in = dfs.open(path);

	    OutputStream out = new BufferedOutputStream(new FileOutputStream(dest));

	    byte[] b = new byte[1024];
	    int numBytes = 0;
	    while ((numBytes = in.read(b)) > 0) {
	        out.write(b, 0, numBytes);
	    }

	    in.close();
	    out.close();
	}
	
	public void run() {
		
		File uploadDir = new File("uploads");
		File eqDir = new File("equalize");
		File canDir = new File("canny");

		if (!uploadDir.exists() || !uploadDir.isDirectory())
			uploadDir.mkdir();
		if (!eqDir.exists() || !eqDir.isDirectory())
			eqDir.mkdir();
		if (!canDir.exists() || !canDir.isDirectory())
			canDir.mkdir();
		
		try {
			serverSocket = new ServerSocket(port);
			System.out.println("Listening for jobs on port "+port);
		} 
		catch (IOException e) {
			System.err.println
			("Could not listen on port for jobs: "+port);
		}

		while (true) {
			doEq = false;
			doCan = false;
			
			Socket clientSocket = null;
			try {
				clientSocket = serverSocket.accept();
			} catch (SocketTimeoutException soe) {
				System.err.println("TIMEOUT OCCURED");
				break;
			} catch (IOException e) {
				System.out.println("Accept failed: " + port);
				System.exit(-1);
			}

			try {
				BufferedReader in = new BufferedReader (new 
				        InputStreamReader(clientSocket.getInputStream()));
				PrintWriter out = new PrintWriter (clientSocket.getOutputStream(),true);
				
				String instring = in.readLine();
				if (instring == null) {
					
					System.out.println("Huh?");
					clientSocket.close();
					continue;
				}
				if (!instring.equals("N")) {
		            out.println("The server got this: " + instring);
		            System.out.println("The server got this: " + instring);
		            filename = instring.substring(1);
		            doEq = true;
				}
	            instring = in.readLine();
	            
	            instring = in.readLine();
	            if (!instring.equals("N")) {
	            	out.println("The server got this: " + instring);
	            	System.out.println("The server got this: " + instring);
	            	filename = instring.substring(1);
	            	doCan = true;
	            }
	            
	            clientSocket.close();
	            
	            String url = address + "pictureUpload/uploads/" + filename;
	            System.err.println("url is: " + url + "\n");
	            URL site = new URL(url);
				
				String filepath = "uploads/" + filename;
				File file = new File(filepath);
				try {
					org.apache.commons.io.FileUtils.copyURLToFile(site, file);
				} catch (Exception e) {
					System.err.println("Don't know\n");
				}

	           
				String path = file.getCanonicalPath();
				System.err.println("path is " + path);
				
				if (doEq == true) {
					executor.execute(new runJarRun(file,"HistEq.jar","equalize",filename));
				}
				if (doCan == true) {
					executor.execute(new runJarRun(file,"EdgeDetect.jar","canny",filename));
				}

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

	}
}
