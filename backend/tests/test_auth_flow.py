from django.urls import reverse
from django.test import TestCase
from rest_framework.test import APIClient


class AuthFlowTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_signup_signin_cycle(self):
        payload = {
            'email': 'tester@example.com',
            'full_name': 'Test User',
            'password': 'testing123',
        }
        signup = self.client.post(reverse('accounts:signup'), payload, format='json')
        self.assertEqual(signup.status_code, 201)
        self.assertIn('access', signup.data)
        self.assertIn('refresh', signup.data)

        signin = self.client.post(
            reverse('accounts:signin'),
            {'email': payload['email'], 'password': payload['password']},
            format='json',
        )
        self.assertEqual(signin.status_code, 200)
        token = signin.data['access']

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        me = self.client.get(reverse('accounts:me'))
        self.assertEqual(me.status_code, 200)
        self.assertEqual(me.data['email'], payload['email'])
