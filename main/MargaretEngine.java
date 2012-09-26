package imghadoop.main;

import edu.cooper.ee.distributed.webconnect.MargaretWebConnection;
public class MargaretEngine {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String address = args[0];
		MargaretWebConnection web = new MargaretWebConnection(args[1],address);
		web.start();
	}

}
