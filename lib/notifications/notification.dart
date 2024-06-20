import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chatapp-a5146",
      "private_key_id": "646d352b8675545cc9bc5d9253f9c3d7f2debcd7",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAWqOuDfUjnHj5\nOnKl5F6cYFiCF3XFeCVO7ZWerW0afEdtiKwC3LNDIeHkQT0SRXuIzP+9OUGHWRrV\neCsWP9R1XNw+jNqEN9ElSZqp28k3L0V74O44fZomcDvhn3u86WTFPzEGT1Zw8fpk\nwDEhxSmorrglW+ndHTK1lBBHO4zVvl+PSbgErK1LEkE4+UPCl9OzTwXNpktSjwXI\nTjbe/E772Llv/5VFECiPX0tDSLr8yNg8Rgus/G8m/u5iAc358gpRqYqNvWOfjtxx\n0tTUukcaGy9RTrgNA9J9o9hTfVmIPu6sb8WXYEgxoNqXAPdGTxq9qufi5jvW9k8O\nX4tTMkjpAgMBAAECggEAM1M8H4JL6c+jm+TTmJ5B/HncxAGchC9VzSSp6qgd15ZX\nvMteEnlvP7d3vd8Ge6yclNkWWBhB+up0tYcWAB7SAurfPbV5zRPTs55bLX2eyCHN\n6YsQJXSmQCFsaPyUGMkyAUumOifLSeHXTTDXK0qfngnYyucmlMBouniii09BefqW\nIHh2l7JnHPK5pYHCB6+SnjhquUqjwh3x8WYmurX711z+aLDgIvGm+on46oyegbZ9\n+Jegbh7BZ5c2ppRCYEI07wTFWiD+tiDOnO4ZNWOrykCJbOIjr0b5wX6A843/afUU\n3dgOZeQD++E5G04anWiu1w/C3NIolpXNjVix76BRbQKBgQD1ci787CB+RP/vmlZw\nuSiHP11kn9PTyQaSSUyA7PWssXsEjs8aCU0vN7aNEaZhH4KFODHhDGKQxzpwtnOT\n3mx28FUBz/+zBAridEygZkB6CO3AgCkO85aGnSyKRRNrh16PPtjTHQI9CQjW13ey\nHsf5/keK1cizxV3TPSLDlNFnNwKBgQDIoAfu0JDEw/ZRyr0fo3oRnrhF6AQUTMxc\n2AccXXCSUFOjUSIQZbxqqeAADJLrlJ6Alljte2oE7ehTIYWEZSZQYwSgaiUINUfb\nKdtRB6ZrYRMlKOb+0mL9X4wZ3aaJl5UR7Y3d/4lOE7cFbIrHd52rRREXRWdaLYWg\nRHI9R3Gg3wKBgGWvQ3Y3IRMO5PVP/IXAv+CgSMHaUTjJbLaINXCoOvOrp6pwu64u\nslJgg3mYGVTdaAZnDIsOxXrzfuuZOvLE0CzKTn1svaNdhmDhC6ncEtQ8BLuenOP7\n2J22WfCCw5PlxjAUOmHj/7xnlMjlBUq+49xXEy6aeQa5OrC8AD4E1mgrAoGALVS7\ndiJ6E3uTtHdytCtj8YdDa8g4471Wj8PgF3CldunffA9g+wOBxzgK/PfaWpCCH9vY\nzBAOrH50+BOi739LYO5+pSBWrbwcOFEE1RI9cBXHFaZgS0OOSmHEbjO+5WfyrtJW\nM8sBYzrhJ8CWuus0HPbGHdP4vk962fOdPGtgKVECgYEA2tvtHw3MEUTefS/LqsPb\nGMu4fMNml/PqiHPzaWyaE7olEW70KrUqE742oYlRyaKVpplmSwyec6SwRdzZ20PA\nhz7TENUGkJQZeluhGnZm+h1Hcp2AFIZgyBsQhRPVehp3jK86gAmzAqgL2fmFITbA\nI+vS3MGCpDRs6cbW8gonI2M=\n-----END PRIVATE KEY-----\n",
      "client_email": "aakash-chat-app@chatapp-a5146.iam.gserviceaccount.com",
      "client_id": "118407481123943363793",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/aakash-chat-app%40chatapp-a5146.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/firebase.database'
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/chatapp-a5146/message:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'New Trip Request',
          'body': 'This is body',
        },
        'data': {
          'tripID': 0,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String,String>{
        // 'Contec'
      }
    );
  }
}
