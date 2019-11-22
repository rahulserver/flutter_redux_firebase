package com.example.flutter_redux_firebase.utils;

import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.auth.BasicAuthorization;
import twitter4j.conf.ConfigurationBuilder;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Created by rahulserver on 4/22/2016.
 */
public class XAuthUtils {
    public static final String MAC_CONSUMER_KEY = "CjulERsDeqhhjSme66ECg";
    public static final String MAC_CONSUMER_SECRET = "IQWdVyqFxghAtURHGeGiWAsmCAGmdW3WmbEx6Hck";

    public static AccessToken chkLogin(String username, String password) {
        System.setProperty("twitter4j.oauth.consumerKey", MAC_CONSUMER_KEY);
        System.setProperty("twitter4j.oauth.consumerSecret", MAC_CONSUMER_SECRET);

        Twitter twitter = new TwitterFactory().getInstance(new BasicAuthorization(username, password));
        try {
            AccessToken accessToken = twitter.getOAuthAccessToken();
            return accessToken;
        } catch (TwitterException e) {
            return null;
        }
    }

    public static String traceToString(Throwable t) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        t.printStackTrace(pw);
        return sw.toString(); // stack trace as a string
    }

    public static BooleanExceptionResult postTweet(AccessToken token, String tweet) {
        try {
            ConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
            configurationBuilder.setOAuthConsumerKey(MAC_CONSUMER_KEY);
            configurationBuilder.setOAuthConsumerSecret(MAC_CONSUMER_SECRET);
            configurationBuilder.setOAuthAccessToken(token.getToken());
            configurationBuilder.setOAuthAccessTokenSecret(token.getTokenSecret());

            Twitter twitter = new TwitterFactory(configurationBuilder.build()).getInstance();
            Status s = twitter.updateStatus(tweet);
            return new BooleanExceptionResult(true, null, 1);
        } catch (TwitterException e) {
            return new BooleanExceptionResult(false, traceToString(e), e.getErrorCode());
        } catch (Exception e) {
            return new BooleanExceptionResult(false, traceToString(e), 0);
        }
    }

}