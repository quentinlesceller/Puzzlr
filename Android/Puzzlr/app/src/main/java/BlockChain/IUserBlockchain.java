package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
public interface IUserBlockchain {

    /**
     * Gets the registered.
     *
     * @param user
     *            the user
     * @return the registered
     */
    boolean getRegistered(String user);

    /**
     * Register user.
     *
     * @param user
     *            the user
     * @param hash
     *            the hash
     * @return true, if successful
     */
    boolean registerUser(String user, String hash);

    /**
     * Delete user.
     *
     * @param user
     *            the user
     * @param hash
     *            the hash
     * @return true, if successful
     */
    boolean deleteUser(String user, String hash) throws JSONException;

    /**
     * Query hash.
     *
     * @param user
     *            the user
     * @param hash
     *            the hash
     * @return true, if successful
     */
    boolean login(String user, String hash) throws JSONException;
}