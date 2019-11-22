package com.example.flutter_redux_firebase.utils;

/**
 * Created with IntelliJ IDEA.
 * User: Rahulserver
 * Date: 5/24/15
 * Time: 3:45 PM
 * To change this template use File | Settings | File Templates.
 */
public class BooleanExceptionResult {
    boolean result;
    String exception;
    int code;


    public BooleanExceptionResult(boolean result, String exception, int code) {
        this.result = result;
        this.exception = exception;
        this.code = code;
    }

    public boolean isResult() {
        return result;
    }

    public void setResult(boolean result) {
        this.result = result;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getException() {
        return exception;
    }

    public void setException(String exception) {
        this.exception = exception;
    }
}