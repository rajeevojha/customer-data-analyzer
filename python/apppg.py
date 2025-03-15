from fastapi import FastAPI, Request, HTTPException
import jwt
from sqlalchemy import create_engine, text
import os

app = FastAPI()

# Postgres (swap host: <rds-endpoint> AWS, 34.83.253.65 GCP)
engine = create_engine('postgresql://postgres:Sw33t0Rang3@customers.c9sa2ks60dfr.us-west-1.rds.amazonaws.com:5432/customers')
JWT_SECRET = 'your-secret-key'

def verify_token(request: Request):
    auth_header = request.headers.get('Authorization')
    if not auth_header or 'Bearer ' not in auth_header:
        raise HTTPException(status_code=401, detail='No token')
    token = auth_header.split(' ')[1]
    try:
        jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
    except:
        raise HTTPException(status_code=403, detail='Invalid token')

@app.post('/login')
async def login(username: str):
    if not username:
        raise HTTPException(status_code=400, detail='Missing username')
    token = jwt.encode({'username': username}, JWT_SECRET, algorithm='HS256')
    return {'token': token}

@app.get('/users')
async def get_users(request: Request):
    verify_token(request)
    try:
        with engine.connect() as conn:
            result = conn.execute(text('SELECT * FROM users')).fetchall()
            users = [{'id': row[0], 'name': row[1], 'activity': row[2]} for row in result]
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=3000)
