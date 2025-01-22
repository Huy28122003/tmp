package com.example.tmp;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    public String getArpTable() {
        StringBuilder arpTable = new StringBuilder();
        try {
            Process process = Runtime.getRuntime().exec("cat /proc/net/arp");
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                arpTable.append(line).append("\n");
            }
            bufferedReader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return arpTable.toString();
    }
}
