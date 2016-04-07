package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
public class PublicKeyBlockchain implements IPublicKeyBlockchain {

    /** The blockchain. */
    OpenBlockchain blockchain;

    /** The user blockchain. */
    UserBlockchain userBlockchain;

    /** The type. */
    String type;

    /** The name. */
    String name;

    /**
     * Instantiates a new public key blockchain.
     *
     * @param address
     *            the address
     * @param port
     *            the port
     */
    public PublicKeyBlockchain(String address, int port) {
        blockchain = new OpenBlockchain(address, port);

        type = "GOLANG";
        name = "40660fec0f8bb30a9452e96abf28ca430faea41a1da5eb8065cbc0e74c8630020708e414f7063885cc8a57def3d4e475672cf5432958b00b04fa75241ff8c7f2";

        userBlockchain = new UserBlockchain(address, port);
    }

    /*
     * (non-Javadoc)
     *
     * @see
     * publickeyblockchain.IPublicKeyBlockchain#registerPublicKey(java.lang.
     * String, java.lang.String)
     */
    @Override
    public boolean registerPublicKey(String user, String publicKey) {
        boolean success = true;
        String[] args = { user, publicKey };

        if (!userBlockchain.getRegistered(user)) {
            blockchain.invoke(type, name, "invoke", args);
        } else {
            success = false;
        }

        return success;
    }

    /*
     * (non-Javadoc)
     *
     * @see publickeyblockchain.IPublicKeyBlockchain#deletePublicKey(java.lang.
     * String, java.lang.String)
     */
    @Override
    public boolean deletePublicKey(String user, String hash) throws JSONException {
        boolean success = true;
        String[] args = { user };

        if (userBlockchain.login(user, hash)) {
            blockchain.invoke(type, name, "delete", args);
        } else {
            success = false;
        }

        return success;
    }

    /*
     * (non-Javadoc)
     *
     * @see
     * publickeyblockchain.IPublicKeyBlockchain#queryPublicKey(java.lang.String)
     */
    @Override
    public String queryPublicKey(String user) {
        String publicKey = null;
        String[] args = { user };

        if (userBlockchain.getRegistered(user)) {
            JSONObject result;

            result = blockchain.query(type, name, "query", args);

            try {
                publicKey = result.getString("OK");

            } catch (JSONException e) {

                e.printStackTrace();
            }

        }

        return publicKey;

    }

}