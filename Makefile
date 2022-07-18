
WINDRES := windres.exe
RES_SOURCE := resources\resource.rc
RES := resource.res
APP := demo2

CC := nim.exe
CC_FLAGS := c -d:release --app:gui --passL:-s --link:${RES}

all: ${APP}


${APP}: ${RES}
	${CC} ${CC_FLAGS} $@


${RES}: ${RES_SOURCE}
	${WINDRES} -i  $< -O coff -o $@

clean:
	@cmd /c del ${APP}.exe ${RES}