# Godelive

This is an opinionated install of [Mopidy](https://mopidy.com/) to be used as the driving software for [GodeLIVE](https://radio.godelievefeesten.be/), the live pop-up "radio" at the annual festival [Godelievefeesten](https://www.godelievefeesten.be/).

Run as:

```
docker run -ti --rm \
  -p 6680:6680 -p 6600:6600 -p 5555:5555/udp \
  -v $MOPIDY_CONFIG_DIR:/mnt/mopidy/config \
  -v $MOPIDY_DATA_DIR:/mnt/mopidy/data \
  -v $MOPIDY_IRISDATA_DIR:/mnt/iris/data \
  -v $MOPIDY_MEDIA_DIR:/mnt/media \
  -v $MOPIDY_PLAYLISTS_DIR:/mnt/playlists \
  godelive
```
