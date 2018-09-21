#define _GNU_SOURCE
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define PORT 8000

#define GET_NADAACONTECEU (0<<8)
#define GET_DADO (1<<8)
#define GET_NOVACONEXAO (2<<8)
#define GET_CONEXAOFECHADA (3<<8)

#define PUT_DADO (0<<8)
#define PUT_FECHARCONEXAO (1<<8)

static int server_fd = -1;
static int socket_fd = -1;

static void socket_init() {
	server_fd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
	if (server_fd < 0)
		goto fail;

	struct sockaddr_in serv_addr;
	memset(&serv_addr, 0, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(PORT);
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	if (bind(server_fd,
			(struct sockaddr *) &serv_addr,
			sizeof(serv_addr)) < 0)
		goto fail;

	if (listen(server_fd, 5) < 0)
		goto fail;

	return;
fail:;
	perror("socket_init");
	server_fd = -1;
}

unsigned int socket_accept() {
	socket_fd = accept4(server_fd, NULL, NULL, SOCK_NONBLOCK);
	if (socket_fd < 0) {
		if (errno != EAGAIN && errno != EWOULDBLOCK)
			// EAGAIN ou EWOULDBLOCK são normais por causa do NONBLOCK
			perror("accept");
		return GET_NADAACONTECEU;
	}
	return GET_NOVACONEXAO;
}

unsigned int socket_get() {
	if (server_fd < 0) {  // primeira vez que a função é chamada
		socket_init();
		return GET_NADAACONTECEU;
	}

	if (socket_fd < 0) {
		return socket_accept();
	}

	uint8_t buf;
	ssize_t res = recv(socket_fd, &buf, sizeof(buf), 0);
	if (res == 0 || (res < 0 && (errno == ENOTCONN || errno == EBADF))) {
		socket_fd = -1;
		return GET_CONEXAOFECHADA;
	}
	else if (res < 0) {
		if (errno != EAGAIN && errno != EWOULDBLOCK)
			// EAGAIN ou EWOULDBLOCK são normais por causa do NONBLOCK
			perror("recv");
		return GET_NADAACONTECEU;
	}

	assert(res == sizeof(buf));
	return GET_DADO | buf;
}

void socket_put(unsigned int val) {
	if ((val & PUT_FECHARCONEXAO) == PUT_FECHARCONEXAO) {
		close(socket_fd);
		return;
	}

	if ((val & PUT_DADO) == PUT_DADO) {
		uint8_t buf = val & (~PUT_DADO);
		while (1) {
			if (send(socket_fd, &buf, sizeof(buf), 0) >= 0)
				break;
			if (errno != EAGAIN && errno != EWOULDBLOCK) {
				perror("send");
				break;
			}
		}
	}
}