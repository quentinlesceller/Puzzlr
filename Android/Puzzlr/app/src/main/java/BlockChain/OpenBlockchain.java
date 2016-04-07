package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
import java.net.MalformedURLException;
import java.net.URL;



/**
 * The Class OpenBlockchain.
 *
 * @author Quentin Le Sceller
 */
public class OpenBlockchain {

    /** The server. */
    private String server;

    /** The url tools. */
    private URLTools urlTools;

    /** The use open ssl. */
    private boolean useOpenSSL;

    /** The security enabled. */
    private boolean securityEnabled;

    /** The enroll id. */
    private String enrollID;

    /** The enroll secret. */
    private String enrollSecret;

    /**
     * Instantiates a new open blockchain.
     *
     * @param IP
     *            the ip
     * @param port
     *            the port
     */
    public OpenBlockchain(String IP, int port) {

        server = IP + ":" + port;
        urlTools = new URLTools();
        useOpenSSL = false;

    }

    /**
     * Instantiates a new open blockchain.
     *
     * @param IP
     *            the ip
     * @param port
     *            the port
     * @param enrollID
     *            the enroll id
     * @param enrollSecret
     *            the enroll secret
     */
    public OpenBlockchain(String IP, int port, String enrollID, String enrollSecret) {

        server = IP + ":" + port;
        urlTools = new URLTools();
        useOpenSSL = false;
        securityEnabled = true;
        this.enrollID = enrollID;
        this.enrollSecret = enrollSecret;

    }

    /*
     * (non-Javadoc)
     *
     * @see obc4j.IOpenBLockchain#getBlock(int)
     */

    public JSONObject invoke(String type, String name, String function, String[] args) {
        String request = "/devops/invoke";
        URL url = createURLRequest(request);

        JSONObject response = null;
        try {
            JSONObject chaincodeSpecJSON = new JSONObject();
            chaincodeSpecJSON.put("type", type);

            chaincodeSpecJSON.put("chaincodeID", new JSONObject().put("name", name));

            JSONObject ctorMSg = new JSONObject();
            ctorMSg.put("function", function);

            JSONArray argsArrayJSON = new JSONArray();

            for (String arg : args) {
                argsArrayJSON.put(arg);
            }

            ctorMSg.put("args", argsArrayJSON);
            chaincodeSpecJSON.put("ctorMsg", ctorMSg);

            if (securityEnabled) {
                chaincodeSpecJSON.put("secureContext", enrollID);
            }

            JSONObject bodyJSON = new JSONObject().put("chaincodeSpec", chaincodeSpecJSON);

            if (useOpenSSL) {
                response = urlTools.sendHTTPSPost(url, bodyJSON.toString());
            } else {
                response = urlTools.sendPost(url, bodyJSON.toString());
            }

        } catch (JSONException e) {

            e.printStackTrace();
        }

        return response;
    }

    public JSONObject query(String type, String name, String function, String[] args) {
        String request = "/devops/query";
        URL url = createURLRequest(request);

        JSONObject response = null;
        try {
            JSONObject chaincodeSpecJSON = new JSONObject();
            chaincodeSpecJSON.put("type", type);

            chaincodeSpecJSON.put("chaincodeID", new JSONObject().put("name", name));

            JSONObject ctorMSg = new JSONObject();
            ctorMSg.put("function", function);

            JSONArray argsArrayJSON = new JSONArray();

            for (String arg : args) {
                argsArrayJSON.put(arg);
            }

            ctorMSg.put("args", argsArrayJSON);
            chaincodeSpecJSON.put("ctorMsg", ctorMSg);

            if (securityEnabled) {
                chaincodeSpecJSON.put("secureContext", enrollID);
            }

            JSONObject bodyJSON = new JSONObject().put("chaincodeSpec", chaincodeSpecJSON);

            if (useOpenSSL) {
                response = urlTools.sendHTTPSPost(url, bodyJSON.toString());
            } else {
                response = urlTools.sendPost(url, bodyJSON.toString());
            }

        } catch (JSONException e) {

            e.printStackTrace();
        }

        return response;

    }

    public void enableOpenSSL() {
        useOpenSSL = true;

    }

    /**
     * Creates the url request.
     *
     * @param request
     *            the request
     * @return the url
     */
    private URL createURLRequest(String request) {
        URL url = null;

        if (useOpenSSL) {
            try {
                url = new URL("https://" + server + request);
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
        } else {
            try {
                url = new URL("http://" + server + request);
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
        }

        return url;
    }

    public Boolean registrarUser() {
        Boolean success = null;
        if (securityEnabled) {
            success = false;
            String request = "/registrar";
            URL url = createURLRequest(request);

            JSONObject response = null;
            try {
                JSONObject bodyJSON = new JSONObject();
                bodyJSON.put("enrollID", enrollID);
                bodyJSON.put("enrollSecret", enrollSecret);

                if (useOpenSSL) {
                    response = urlTools.sendHTTPSPost(url, bodyJSON.toString());
                } else {
                    response = urlTools.sendPost(url, bodyJSON.toString());
                }
                if (response.getString("OK").contains("Login successful")) {
                    success = true;
                }

            } catch (JSONException e) {

                e.printStackTrace();
            }

        }
        return success;
    }

    public Boolean getRegistrar(String enrollmentID) {
        Boolean success = null;
        if (securityEnabled) {
            success = false;
            String request = "/registrar/" + enrollmentID;
            URL url = createURLRequest(request);

            JSONObject registrarJSON = null;

            if (useOpenSSL) {
                registrarJSON = urlTools.getHTTPSJSON(url);
            } else {
                registrarJSON = urlTools.getJSON(url);
            }

            try {
                if (registrarJSON.getString("OK").contains("is already logged in.")) {
                    success = true;
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
        return success;
    }

    public String getEnrollmentCertificate(String enrollmentID) {
        String response = null;
        if (securityEnabled) {

            String request = "/registrar/" + enrollmentID + "/ecert";
            URL url = createURLRequest(request);

            JSONObject registrarJSON = null;

            if (useOpenSSL) {
                registrarJSON = urlTools.getHTTPSJSON(url);
            } else {
                registrarJSON = urlTools.getJSON(url);
            }

            try {
                response = registrarJSON.getString("OK");

            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
        return response;

    }

}