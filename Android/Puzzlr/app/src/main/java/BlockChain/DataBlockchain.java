package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
import java.util.LinkedHashMap;
public class DataBlockchain implements IDataBlockchain {
    /** The blockchain. */
    OpenBlockchain blockchain;

    /** The type. */
    String type;

    /** The name. */
    String name;

    Hash hash;

    /**
     * Instantiates a new user blockchain.
     *
     * @param address
     *            the address
     * @param port
     *            the port
     */
    public DataBlockchain(String address, int port) {
        blockchain = new OpenBlockchain(address, port);

        type = "GOLANG";
        name = "de43e35f88de8c990310e91aefe3b91c01afffc548bca072070f2650165aef805f3ef7674696c8d84e4d572d420d0eb418477414dd76bac7748ef95cb5dba0fe";

        hash = new Hash();
    }

    /*
     * (non-Javadoc)
     *
     * @see imageblockchain.IImageBlockchain#sendMessage(java.lang.String,
     * java.lang.String)
     */
    @Override
    public void sendMessage(String username, String data) {

        String hashValue = hash.getSHA256(data);

        String[] argsUserMessages = { username, hashValue };
        String[] argsMessage = { hashValue, data };

        blockchain.invoke(type, name, "invoke", argsUserMessages);
        blockchain.invoke(type, name, "invoke", argsMessage);

    }

    /*
     * (non-Javadoc)
     *
     * @see imageblockchain.IImageBlockchain#getAllMessages(java.lang.String)
     */
    @Override
    public LinkedHashMap<String, String> getAllMessages(String username) {
        LinkedHashMap<String, String> listMessages = new LinkedHashMap<>();

        String rawHashes;

        String[] args = { username };

        JSONObject hashesJSON;

        hashesJSON = blockchain.query(type, name, "query", args);

        try {
            rawHashes = hashesJSON.getString("OK");

            // Loop on the hashes contained in an username.
            for (int i = 0; i < rawHashes.length() / 64; i++) {
                String hash = rawHashes.substring(i * 64, 64 * (i + 1));
                String[] arghash = { hash };
                JSONObject dataJSON = blockchain.query(type, name, "query", arghash);
                String value = dataJSON.getString("OK");
                listMessages.put(hash, value);

                //deleteData(hash);
            }
            //deleteData(username);

        } catch (JSONException e) {

            e.printStackTrace();
        }

        return listMessages;
    }

    private void deleteData(String key) {

        String[] args = { key };

        blockchain.invoke(type, name, "delete", args);

    }

}