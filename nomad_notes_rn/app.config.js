module.exports = {
  expo: {
    name: 'Nomad Notes',
    slug: 'nomad-notes-rn',
    version: '1.0.0',
    orientation: 'portrait',
    userInterfaceStyle: 'light',
    ios: {
      supportsTablet: true,
      bundleIdentifier: 'com.nomadnotes.app',
    },
    android: {
      package: 'com.nomadnotes.app',
    },
    extra: {
      // Read from environment variable or .env file
      apiUrl: process.env.NOMAD_API_URL || process.env.EXPO_PUBLIC_API_URL,
    },
  },
};
