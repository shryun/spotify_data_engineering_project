import boto3 # aws sdk for python
import json
import spotify
from spotipy.oauth2 import SpotifyClientCredentials
from datetime import datetime
import os
import asyncio
# if no async(request) and call 3 apis at the same time, it will take 10s * 3 = 30s
# with async, it will take 10s + a little overhead = 10s

def lambda_handler(event, context):
    # get the tokens
    client_credentials_manager = SpotifyClientCredentials(
        client_id=os.getenv("CLIENT_ID"),
        client_secret=os.getenv("CLIENT_SECRET")
    )

    '''
    secret_name = "spotify-api-credentials"
    region_name = os.environ.get("AWS_REGION", "us-east-1")

    client = boto3.client('secretsmanager', region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])

    CLIENT_ID = secret['CLIENT_ID']
    CLIENT_SECRET = secret['CLIENT_SECRET']
    '''

    # create the spotify object(controller) to get the api data
    sp = spotify.Spotify(client_credentials_manager=client_credentials_manager)
    
    playlists = sp.user_playlists('spotify')
    playlist_link = "https://open.spotify.com/playlist/37i9dQZF1DX7aUUBCKwo4Y"
    playlist_URI = playlist_link.split("/")[-1]
    spotify_data = sp.playlist_tracks(playlist_URI)

    # store data in s3
    s3_client = boto3.client('s3')
    filename = "playlist_raw_" + str(datetime.now()) + ".json"

    s3_client.put_object(
        Bucket="spotify-datalake-216989135823", # replace with your bucket name
        Key="raw/" + filename,
        Body=json.dumps(spotify_data)
    )
    return {
        'statusCode': 200,
        'body': json.dumps('Spotify data fetched and stored in S3 successfully!')
    }


# Activate your virtual environment
# source venv/bin/activate   # Linux/Mac

# Generate requirements.txt
# pip freeze > requirements.txt
