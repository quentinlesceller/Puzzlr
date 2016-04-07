package BlockChain;

/**
 * Created by aniss on 09/03/16.
 */

import android.widget.Toast;

import security.BCrypt;

/**
 * The Class UserBlockchain.
 *
 * @author Quentin Le Sceller
 */
public class UserBlockchain implements IUserBlockchain {

    /** The blockchain. */
    OpenBlockchain blockchain;

    /** The type. */
    String type;

    /** The name. */
    String name;

    /**
     * Instantiates a new user blockchain.
     *
     * @param address
     *            the address
     * @param port
     *            the port
     */
    public UserBlockchain(String address, int port) {
        blockchain = new OpenBlockchain(address, port);
        type = "GOLANG";
        name = "622fa47b0be4cffc3a7e913e72622abe6b224caf83bac5df61bba599e33ad291f3d730c31583ba404d9ad03e91d59f15659f3ff326dc30f71a6f0c12b35ed924";
    }

    /*
     * (non-Javadoc)
     *
     * @see userblockchain.IUserBlockchain#getRegistered(java.lang.String)
     */
    @Override
    public boolean getRegistered(String user) {
        boolean registered = false;
        String[] args = { user };

        JSONObject registeredJSON = blockchain.query(type, name, "query", args);

        try {
            if (registeredJSON.getString("OK").contains("isRegisteredTrue")) {
                registered = true;
            }

        } catch (JSONException e) {

            e.printStackTrace();
        }



        return registered;
    }


    /*
     * (non-Javadoc)
     *
     * @see userblockchain.IUserBlockchain#registerUser(java.lang.String,
     * java.lang.String)
     */
    @Override
    public boolean registerUser(String user, String hash) {
        boolean success = true;
        String[] args = { user, hash };

        if (!getRegistered(user)) {
            blockchain.invoke(type, name, "invoke", args);
        } else {
            success = false;
        }

        return success;
    }

    /*
     * (non-Javadoc)
     *
     * @see userblockchain.IUserBlockchain#deleteUser(java.lang.String,
     * java.lang.String)
     */
    @Override
    public boolean deleteUser(String user, String hash) throws JSONException {
        boolean success = true;
        String[] args = { user };

        if (login(user, hash)) {
            blockchain.invoke(type, name, "delete", args);
        } else {
            success = false;
        }

        return success;
    }

    /*
     * (non-Javadoc)
     *
     * @see userblockchain.IUserBlockchain#queryHash(java.lang.String,
     * java.lang.String)
     */
    @Override
    public boolean login(String user, String password) throws JSONException {
        boolean success = false;
        String[] args = { user, password };


        if (getRegistered(user)) {
            JSONObject result;


            result = blockchain.query(type, name, "query", args);

            String retrievedHashedPassword = result.getString("OK");

            BCrypt bCrypt = new BCrypt();



            if(bCrypt.checkpw(password, retrievedHashedPassword)){

                success = true;
            }





        }

        return success;
    }

}