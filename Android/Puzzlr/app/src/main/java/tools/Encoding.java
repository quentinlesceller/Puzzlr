package tools;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.util.Base64;
import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Iterator;

/**
 * Created by aniss on 09/03/16.
 */
public class Encoding {


    public String encodeImage(byte[] imageByteArray){
        return Base64.encodeToString(imageByteArray, Base64.DEFAULT);
    }


    public byte[] decodeImage(String imageDataString){

        return Base64.decode(imageDataString, Base64.DEFAULT);

    }





    public byte[] bitmapToByteArray(Bitmap bitmap){
        int size = byteSizeOf(bitmap);



        ByteBuffer buffer = ByteBuffer.allocate(size);
        bitmap.copyPixelsToBuffer(buffer);

        return buffer.array();

    }

    public Bitmap byteArrayToBitmap(byte[] data, int width, int height, Bitmap.Config config){
        Bitmap bitmap = Bitmap.createBitmap(width, height, config);
        ByteBuffer buffer = ByteBuffer.wrap(data);
        bitmap.copyPixelsFromBuffer(buffer);

        return bitmap;
    }


    protected int byteSizeOf(Bitmap data) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB_MR1) {
            return data.getRowBytes() * data.getHeight();
        }
        else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            return data.getByteCount();
        }
        else {
            return data.getAllocationByteCount();
        }
    }


}
