# Network Connectivity Debugging

## Current Issue

```
✅ [API Config] Using API URL from environment: http://10.0.56.2:8000
❌ [SignIn] Failed: Cannot connect to server
```

The app knows the correct URL, but can't reach it.

---

## Diagnostic Steps

### Step 1: Test from iOS Simulator

Open **Safari** in the iOS Simulator and try to access the backend:

```
1. In iOS Simulator, open Safari
2. Go to: http://10.0.56.2:8000/api/docs/
3. Does it load?
   - YES → Backend is reachable from simulator
   - NO → Network configuration issue
```

---

### Step 2: Test from Development Host

From your macOS terminal:

```bash
# Test if backend is accessible from your Mac
curl -I http://10.0.56.2:8000/api/docs/

# Should return: HTTP/1.1 200 OK
```

---

### Step 3: Check Backend is Listening on 0.0.0.0

The backend **MUST** listen on `0.0.0.0` (all interfaces), not `127.0.0.1` (localhost only):

**On backend host (10.0.56.2):**

```bash
# Check what address Django is binding to
docker compose logs backend | grep "Starting development server"

# Should show:
# Starting development server at http://0.0.0.0:8000/
# NOT: http://127.0.0.1:8000/
```

**If it shows 127.0.0.1, fix it:**

```bash
# In docker-compose.yml, ensure command is:
command: python manage.py runserver 0.0.0.0:8000

# Restart:
docker compose down
docker compose up
```

---

### Step 4: Test Network Route

Check if iOS simulator can reach the backend host:

```bash
# From your Mac terminal:

# 1. Check if 10.0.56.2 is reachable
ping -c 3 10.0.56.2

# 2. Check if port 8000 is open
nc -zv 10.0.56.2 8000

# 3. Make actual HTTP request
curl -v http://10.0.56.2:8000/api/docs/
```

---

### Step 5: Check Firewall on Backend Host

On the backend host (10.0.56.2), ensure port 8000 is not blocked:

**macOS:**
```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# If enabled, allow Python/Docker
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/bin/python3
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock /usr/bin/python3
```

**Linux:**
```bash
# Check if port 8000 is allowed
sudo ufw status
sudo iptables -L | grep 8000

# Allow port 8000
sudo ufw allow 8000
```

---

### Step 6: Test with Simple HTTP Request

Add this test button to SignInScreen to diagnose:

```typescript
// Temporary test button
<Button
  onPress={async () => {
    try {
      console.log('[Test] Attempting to fetch from:', 'http://10.0.56.2:8000/api/docs/');
      const response = await fetch('http://10.0.56.2:8000/api/docs/');
      console.log('[Test] Response status:', response.status);
      console.log('[Test] Response headers:', response.headers);
      alert('Success! Status: ' + response.status);
    } catch (error) {
      console.error('[Test] Fetch failed:', error);
      alert('Failed: ' + error.message);
    }
  }}
>
  Test Network
</Button>
```

---

## Common Issues & Solutions

### Issue 1: Backend on Different Network

**Symptom:** `ping 10.0.56.2` fails from development host

**Solution:**
- Both hosts must be on same network
- Or use VPN/tunnel to connect networks
- Or run backend on same host as development

---

### Issue 2: Backend Listening on 127.0.0.1

**Symptom:** `curl localhost:8000` works on backend host, but `curl 10.0.56.2:8000` fails

**Solution:**
```bash
# Update docker-compose.yml
services:
  backend:
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
```

---

### Issue 3: Firewall Blocking Port 8000

**Symptom:** `ping 10.0.56.2` works, but `nc -zv 10.0.56.2 8000` fails

**Solution:**
```bash
# On backend host, allow port 8000
sudo ufw allow 8000
# or
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
```

---

### Issue 4: iOS Simulator Network Isolation

**Symptom:** Safari in simulator can't access internet

**Solution:**
```bash
# Restart simulator
xcrun simctl shutdown all
open -a Simulator

# Or reset network settings in simulator:
# Settings > General > Transfer or Reset > Reset > Reset Network Settings
```

---

### Issue 5: Docker Network Mode

**Symptom:** Backend in Docker can't be reached from outside

**Solution:**

```yaml
# In docker-compose.yml
services:
  backend:
    network_mode: "host"  # Use host network
    # OR
    ports:
      - "0.0.0.0:8000:8000"  # Bind to all interfaces
```

---

## Quick Diagnostic Script

Run this on your development host:

```bash
#!/bin/bash
echo "=== Network Diagnostics ==="
echo ""

echo "1. Testing backend host reachability..."
ping -c 2 10.0.56.2

echo ""
echo "2. Testing port 8000..."
nc -zv 10.0.56.2 8000

echo ""
echo "3. Testing HTTP..."
curl -I http://10.0.56.2:8000/api/docs/

echo ""
echo "4. Testing from simulator..."
echo "   Please open Safari in simulator and go to:"
echo "   http://10.0.56.2:8000/api/docs/"
echo "   Does it work? (yes/no)"
```

---

## What to Check Next

After running diagnostics, report:

1. **Can Safari in simulator access `http://10.0.56.2:8000/api/docs/`?**
   - YES → Issue is with React Native networking
   - NO → Issue is with network routing/firewall

2. **Can your Mac access `http://10.0.56.2:8000/api/docs/`?**
   - YES → iOS simulator has network issue
   - NO → Backend not accessible over network

3. **What do the new logs show?**
   After adding logging, check Metro output for:
   ```
   [API Client] Making request: ...
   [API Client] Response error: ...
   ```

4. **Backend listening address:**
   ```bash
   docker compose logs backend | grep "Starting development server"
   ```
   Should show: `http://0.0.0.0:8000/`

---

## Temporary Workaround: Use Localhost

If backend is on same machine, try localhost:

```bash
# Create .env
echo "NOMAD_API_URL=http://localhost:8000" > .env

# Restart app
npm run ios
```

**Note:** This only works if backend is running on the same Mac as the simulator.

---

## Next Steps

1. **Add detailed logging** (done - reload app to see logs)
2. **Test with Safari** in simulator
3. **Check backend logs** on backend host
4. **Verify network connectivity** with diagnostic commands above

Report back with:
- Safari test result
- New log output from Metro
- Backend listening address
- Network diagnostic results
