# Install dependencies only when needed
FROM strapi/strapi:alpine AS deps
WORKDIR /srv/app

COPY . .
RUN yarn install --frozen-lockfile

# Rebuild the source code only when needed
FROM strapi/strapi:alpine AS builder
WORKDIR /srv/app
ENV NODE_ENV production

COPY . .
COPY --from=deps ./srv/app/node_modules ./node_modules
RUN yarn build && yarn install --production --ignore-scripts --prefer-offline
# Install plugins
RUN strapi install graphql

# Production image, copy all the files and run app
FROM strapi/strapi:alpine AS runner
WORKDIR /srv/app
ENV NODE_ENV production

COPY --from=builder /srv/app ./

EXPOSE 1337

CMD ["yarn", "start"]
