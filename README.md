# Azure Load Balancer

Azure Load Balancer (ALB) is a Layer 4 (TCP/UDP) service that distributes network traffic across multiple virtual
machines (VMs) to ensure availability and reliability.

## What's done

- Blue backend pool: 1 linux vm
- Green backend pool: 1 linux vm
- SSH NAT rule: 44 -> blue slot vm 22
- SSH NAT rule: 45 -> green slot vm 22
- HTTP NAT rule: 81 -> green slot vm 80
- LB rule: 80 -> blue backend pool 80

---

## Main components of ALB

- **Frontend IP Configuration**: Defines the public or private IP used to accept incoming traffic to the load balancer.

- **Backend Pool**: A group of VMs or instances that receive traffic distributed by the load balancer.

- **Load Balancing Rule**: Defines how traffic is distributed from the frontend to the backend pool, specifying
  protocol, port, and health probe.

- **Health Probe**: Monitors the health of backend instances to ensure traffic is only sent to healthy VMs.

- **NAT Rule**: Maps inbound traffic on a specific frontend port to a VM’s private IP and port for direct access.

- **Outbound Rule**: Controls how outbound traffic is handled, allowing backend instances to communicate externally
  using the load balancer’s frontend IP.

- **Floating IP**: Enables direct traffic passthrough without SNAT, useful for high-availability scenarios.

---

## Difference Between Load Balancing Rule and NAT Rule

### **Load Balancer (LB) Rule**

- Distributes traffic across multiple backend VMs.
- Used for high availability and scalability.
- Works at Layer 4 (TCP/UDP).
- Requires a backend pool.

**Example Scenario:**
A web application is hosted on three VMs. An LB rule is created to forward traffic from Public IP:80 to Backend Pool:80.
When users visit the website, traffic is distributed across the three VMs to ensure availability.

### **NAT Rule**

- Forwards traffic from a specific frontend port to a single VM.
- Used for direct access to individual VMs.
- Works at Layer 4 (TCP/UDP).
- Does not require a backend pool.

**Example Scenario:**
A company needs SSH access to two VMs behind a load balancer. Two NAT rules are created:

- Public IP:2201 → VM1:22
- Public IP:2202 → VM2:22
  Admins can connect using `ssh -p 2201 user@public-ip` to access VM1 and `ssh -p 2202 user@public-ip` for VM2.

