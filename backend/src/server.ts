import { app } from './app.js'
import { env } from './config/env.js'
import { prisma } from './db/prisma.js'

const server=app.listen(env.API_PORT,()=>console.info(JSON.stringify({level:'info',message:'Platform API listening',port:env.API_PORT})))

async function shutdown(signal:string){
  console.info(JSON.stringify({level:'info',message:'Shutting down API',signal}))
  server.close(async()=>{await prisma.$disconnect();process.exit(0)})
  setTimeout(()=>process.exit(1),10000).unref()
}
process.on('SIGINT',()=>void shutdown('SIGINT'))
process.on('SIGTERM',()=>void shutdown('SIGTERM'))
