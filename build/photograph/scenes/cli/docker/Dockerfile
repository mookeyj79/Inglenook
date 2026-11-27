FROM busybox AS base
RUN echo ready

FROM base AS slow
RUN sleep 30

FROM base AS broken
RUN sleep 3 && echo "no such file" && exit 1

FROM base
COPY --from=slow /etc/hostname /a
COPY --from=broken /etc/hostname /b
