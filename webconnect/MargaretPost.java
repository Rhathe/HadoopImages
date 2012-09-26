package imghadoop.webconnect;

import java.io.File;
import java.io.IOException;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

public class MargaretPost {

	public MargaretPost(String filename, String address, String inputNameAttr) {
		
		DefaultHttpClient httpclient = new DefaultHttpClient();

		HttpPost method = new HttpPost(address);
		MultipartEntity entity = new MultipartEntity();
		
		File f = new File(filename);
		FileBody fileBody = new FileBody(f);
		entity.addPart(inputNameAttr, fileBody);
		
		method.setEntity(entity);
		HttpContext httpContext = new BasicHttpContext();
		
		try {
			HttpResponse response = httpclient.execute(method,httpContext);
			//HttpEntity rent = response.getEntity();
			System.out.println(response.getStatusLine());
			//rent.writeTo(System.out);
			System.out.println("Upload of " + filename + " to " + address + " is done");
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
