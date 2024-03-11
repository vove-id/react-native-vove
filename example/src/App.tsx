import * as React from 'react';

import { StyleSheet, View, Text, Pressable } from 'react-native';
import { processIDMatching, VoveEnvironment } from 'react-native-vove';
import { useEffect, useRef } from 'react';
import 'react-native-get-random-values';
import { v4 as uuidv4 } from 'uuid';

const AuthURL = 'https://demo-api.voveid.com';
const authToken =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImtoYWxpZCIsInN1YiI6MiwiaWF0IjoxNzA3ODE2NTgyLCJleHAiOjE3MTA0MDg1ODJ9.Bg53pyJzuZxW__vZMs0hgZKCCftCXq8CrmVvrI_gk7c';

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
    const { token } = await response.json();
    return token;
  } catch (e) {
    console.error(e);
  }
};
export default function App() {
  const [result, setResult] = React.useState<number | undefined>();
  const sessionToken = useRef<string | undefined>();

  useEffect(() => {
    startUserSession().then((token) => {
      sessionToken.current = token;
    });
  }, []);
  const onStartPress = () => {
    if (sessionToken.current) {
      processIDMatching(VoveEnvironment.sandbox, sessionToken.current).then(
        setResult
      );
    }
  };

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
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
