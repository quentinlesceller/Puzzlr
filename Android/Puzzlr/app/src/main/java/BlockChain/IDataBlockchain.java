package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */
import java.util.LinkedHashMap;

/**
 * The Interface IImageBlockchain.
 *
 * @author Quentin Le Sceller
 */
public interface IDataBlockchain {

    /**
     * Send message.
     *
     * @param username
     *            the username
     * @param data
     *            the data
     * @return true, if successful
     */
    void sendMessage(String username, String data);


    /**
     * Gets the all messages.
     *
     * @param username
     *            the username
     * @return the all messages
     */
    LinkedHashMap<String, String> getAllMessages(String username);
}