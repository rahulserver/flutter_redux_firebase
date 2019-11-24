package com.example.flutter_redux_firebase.utils;

import android.content.Context;
import jxl.Cell;
import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;
import jxl.write.Label;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

/**
 * Created with IntelliJ IDEA.
 * User: Rahulserver
 * Date: 5/24/15
 * Time: 3:04 PM
 * To change this template use File | Settings | File Templates.
 */
public class ExcelUtils {
    public static ArrayList<Integer> getTweetRowIndices(File excelFile) throws IOException, BiffException {
        ArrayList<Integer> indices = new ArrayList<Integer>();
        Workbook workbook = Workbook.getWorkbook(excelFile);
        Sheet sheet = workbook.getSheet(0);
        int rowCount = sheet.getRows();
        int colCount = sheet.getColumns();
        if (colCount == 1) {
            for (int i = 1; i < rowCount; i++) {
                Cell cell = sheet.getCell(0, i);
                String s = cell.getContents();
                if (s != null && s.trim().length() > 0) {
                    indices.add(i);
                }
            }
        }else{
            for(int i=1;i<rowCount;i++){
                try {
                    Cell cell=sheet.getCell(1,i);
                    String s = cell.getContents();
                    if (s == null || s.trim().length() == 0) {
                        indices.add(i);
                    }
                } catch (Exception e) {
                    indices.add(i);
                }
            }
        }
        //Code to shuffle indices
        long seed = System.nanoTime();
        Collections.shuffle(indices, new Random(seed));
        return indices;
    }

    public static String getTweetAtCell(File excelFile, int rowIndex) throws IOException, BiffException {
        Workbook workbook = Workbook.getWorkbook(excelFile);
        Sheet sheet = workbook.getSheet(0);
        return sheet.getCell(0, rowIndex).getContents();
    }

    public static void putValueInCellModifyOriginalSheet(Context context, File originalExcelFile, String value, int rowIndex, int colIndex)
            throws IOException, BiffException, WriteException {
        Workbook workbook = Workbook.getWorkbook(originalExcelFile);
        File tempFile = new File(context.getFilesDir() + File.separator + "temp.xls");
        WritableWorkbook copy = Workbook.createWorkbook(tempFile, workbook);
        WritableSheet sheet2 = copy.getSheet(0);

        Label l = new Label(colIndex, rowIndex, value);
        sheet2.addCell(l);
        copy.write();
        copy.close();
        workbook.close();

        InputStream inStream = null;
        OutputStream outStream = null;

        inStream = new FileInputStream(tempFile);
        outStream = new FileOutputStream(originalExcelFile);

        byte[] buffer = new byte[1024];

        int length;
        //copy the file content in bytes
        while ((length = inStream.read(buffer)) > 0) {

            outStream.write(buffer, 0, length);

        }

        inStream.close();
        outStream.close();

        //delete the original file
        tempFile.delete();
    }

    public static void main(String[] args) {
        System.out.println("hello world");
    }
}