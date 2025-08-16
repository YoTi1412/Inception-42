# Inception-42

# 0 – Understanding PID 1 in Containers

## What is PID 1 and why is it important?
In any Unix-like operating system, **PID 1** is the very first process started by the kernel when the system boots.  
- On a normal Linux system, that’s something like **`init`**, **`systemd`**, or **`upstart`**.  
- PID 1’s responsibilities:
  1. **Start other processes**.
  2. **Adopt orphaned processes** (if a process loses its parent, PID 1 becomes its parent).
  3. **Reap zombie processes** (remove them from the process table after they finish).

In **Docker**, when you run a container:
- There’s no full OS init system.
- The process you define in your `CMD` or `ENTRYPOINT` becomes **PID 1** inside that container.
- This process runs **directly as the first process** in the namespace — no `systemd` between it and the kernel.

---

## How does it work under the hood in Docker?
1. When you run:
   ```bash
   docker run myimage nginx -g 'daemon off;'
   ```
   Docker:
   - Creates Linux namespaces (PID, network, mount, etc.).
   - Sets up cgroups for resource limits.
   - Launches your command **directly** inside that namespace.

2. That command’s process ID inside the container is `1`:
   ```
   $ docker exec -it mycontainer ps -ef
   PID   USER     TIME  COMMAND
     1   root     0:00  nginx: master process nginx -g daemon off;
    15   root     0:00  ps -ef
   ```

3. Since this PID 1 is **not** a normal init system:
   - It **does not automatically forward signals** (SIGTERM, SIGINT) to child processes unless it’s coded to do so.
   - It **does not automatically reap zombies** unless it calls `wait()` on dead processes.

---

## Why does the subject warn about “hacky patches” like `tail -f` or `sleep infinity`?

The subject is enforcing **Docker best practices**.  
If you run:
```dockerfile
CMD ["tail", "-f", "/dev/null"]
```
you’re essentially keeping the container alive **without actually running your service as PID 1**. This is bad because:
1. **Your real service is now a child process** → it might never receive termination signals (SIGTERM) from Docker, so `docker stop` can hang.
2. **Zombie processes can accumulate** because PID 1 isn’t reaping them.
3. **It breaks restart policies** — Docker can’t detect when your actual service dies, because the PID 1 (`tail`) is still alive.
4. **Performance waste** — you’re holding resources for no reason.
5. **Security risk** — misleading entrypoint can hide what’s really running inside.

---

## Why is it relevant for this project?
The Inception project requires:
- One container per service.
- No background hacks like:
  - `nginx & bash`
  - `sleep infinity`
  - `tail -f /dev/null`
  - `while true; do ...; done`

Instead:
- You must run your **main service in the foreground** so it becomes PID 1.
- Example in NGINX:
  ```bash
  exec nginx -g "daemon off;"
  ```
  `exec` here is important — it replaces the shell with the nginx process, so nginx **becomes PID 1**.
  
- Example in WordPress:
  ```bash
  exec /usr/sbin/php-fpm8.2 -F
  ```
  The `-F` flag runs PHP-FPM in foreground.

- Example in MariaDB:
  ```bash
  exec mysqld --user=mysql --bind-address=0.0.0.0
  ```

---

## Best practice takeaway:
- Always make your main service the PID 1 process in the container.
- If your service spawns child processes, make sure PID 1 can forward signals and reap zombies.
- Use `exec` in your entrypoint scripts to replace the shell with the actual service process.

---

## 📌 Defense answer version:
> “In Docker, the first process that starts inside a container is PID 1. Normally, in a full Linux system, PID 1 is `init` or `systemd`, but in Docker, it’s our main process. PID 1 has special responsibilities like reaping zombies and handling signals. If we use tricks like `tail -f` or `sleep infinity`, PID 1 becomes something else, and our real service won’t receive signals or be monitored correctly. That’s why in my containers, I run services in the foreground using `exec` — for example, nginx runs as `exec nginx -g 'daemon off;'` so it becomes PID 1 directly.”



