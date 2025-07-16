import * as React from 'react';
import { useEffect, useRef } from 'react';

import { Pressable, StyleSheet, Text, View } from 'react-native';
import {
  initialize,
  start,
  VoveEnvironment,
  VoveLocale,
  VoveStatus,
} from '@vove-id/react-native-sdk';
import 'react-native-get-random-values';
import { v4 as uuidv4 } from 'uuid';

const AuthURL = 'https://demo-api.voveid.net';
const authToken =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRlbW9Adm92ZWlkLm5ldCIsInN1YiI6MiwiaWF0IjoxNzMyMDk1MDI3LCJleHAiOjE3MzQ2ODcwMjd9.v0ICdWEDutahoZqGBAUiHPWjFIiW6G0i9_aiC6P3QMw';

const startUserSession = async () => {
  try {
    const body = {
      refId: uuidv4(),
    };
    const response = await fetch(`${AuthURL}/sessions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
    const res = await response.json();
    return res?.token;
  } catch (e) {
    console.error(e);
  }
};
export default function App() {
  const [result, setResult] = React.useState<VoveStatus | undefined>();
  const sessionToken = useRef<string | undefined>();

  useEffect(() => {
    const init = async () => {
      try {
        await initialize({
          environment: VoveEnvironment.Sandbox,
          publicKey:
            '6fc3fb00391916cfcd0e47d3a11a243054413ffcf220f9b3adb8d3c6db307842',
        });
        sessionToken.current = await startUserSession();
      } catch (e) {
        console.error(e);
      }
    };
    init();
  }, []);
  const onStartPress = () => {
    if (sessionToken.current) {
      start({
        environment: VoveEnvironment.Sandbox,
        sessionToken: sessionToken.current,
        enableVocalGuidance: true,
        locale: VoveLocale.AR,
      }).then((res) => {
        setResult(res.status);
        console.log({ action: res.action });
      });
    }
  };

  return (
    <View style={styles.container}>
      {/* eslint-disable-next-line react-native/no-inline-styles */}
      <Text style={{ color: 'red' }}>Result: {result}</Text>
      <Pressable style={styles.button} onPress={onStartPress}>
        <Text>Start ID Matching</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  button: {
    padding: 10,
    marginTop: 20,
    backgroundColor: '#2196F3',
    borderRadius: 5,
  },
});
