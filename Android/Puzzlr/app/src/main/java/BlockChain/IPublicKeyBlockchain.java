package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
public interface IPublicKeyBlockchain {

    /**
     * Register public key.
     *
     * @param user
     *            the user
     * @param publicKey
     *            the public key
     * @return true, if successful
     */
    boolean registerPublicKey(String user, String publicKey);

    /**
     * Delete public key.
     *
     * @param user
     *            the user
     * @param publicKey
     *            the public key
     * @return true, if successful
     */
    boolean deletePublicKey(String user, String publicKey) throws JSONException;

    /**
     * Query public key.
     *
     * @param user
     *            the user
     * @return the string
     */
    String queryPublicKey(String user);
}