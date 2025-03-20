const express = require("express");
const app = express();
const mongoose = require("mongoose");
const multer = require("multer");
const path = require("path");
const cors = require("cors");
app.use(express.json());
app.use(cors());



app.listen(4000, () => { console.log("Server connected in 4000 port")});

mongoose.connect("mongodb://localhost:27017/quality_dept")
  .then(() => {
    console.log("Mongodb Connected Successfully");
  })
  .catch((err) => {
    console.error("Mongodb Connection failed", err);
  });


// "mongodb+srv://sakthivelveld13:0ga3GmgjJZ1V1ZO2@mypros.7qwoi.mongodb.net/mydatabase?retryWrites=true&w=majority"
// Monodb Connection -------------------------------------(Local host COnnection)----------------------------------------------
// mongoose.connect("mongodb://localhost:27017/quality_dept").then(() => { console.log("Mongodb Connected Successfully"); }).catch((err) => { console.error("Mongodb Connection failed", err); });



//======================================================================Router Connection===================================================

const fs = require('fs');
const locats = require("./bridge/location.js");
const departure = require("./bridge/department.js");
const forms = require("./bridge/form.js");
const log = require('./bridge/login.js')
const media = require("./collectin_db/media.js");


//==========================================================================API CALLING==============================================================

app.use('/quality/baseone',locats);  
app.use('/quality/baseone',departure);
app.use('/quality/baseone',forms);
app.use('/quality/baseone',log);



//=========================================================================IMAGE Works=============================================================

const createUploadDirs = () => {
    const videoPath = path.join(__dirname, 'upload/video');
    const imagePath = path.join(__dirname, 'upload/image');

    if (!fs.existsSync(videoPath)) {
        fs.mkdirSync(videoPath, { recursive: true });
    }

    if (!fs.existsSync(imagePath)) {
        fs.mkdirSync(imagePath, { recursive: true });
    }
};

createUploadDirs();

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
      const type = req.body.type;
      const folder = type === "video" ? "upload/video" : "upload/image"; 
      cb(null, folder); 
    },
    filename: (req, file, cb) => {
      cb(null, `${Date.now()}-${file.originalname}`);
    },
  });

const upload = multer({ storage });
app.use("/upload", express.static(path.join(__dirname, "upload")));

//===============================================================================IMAGE POST==============================================================

app.post("/media/upload", upload.single("mediaFile"), async (req, res) => {
    const { title, description, mediaType, videoURL } = req.body;
  
    console.log("Request Body:", req.body);
    console.log("Uploaded File:", req.file);
  
    if (!title || !description || !mediaType) {
      return res.status(400).json({ error: "Title, description, and mediaType are required!" });
    }
  
    if (mediaType === "image" && !req.file) {
      return res.status(400).json({ error: "Image file is required for mediaType 'image'!" });
    }
  
    if (mediaType === "video" && !videoURL) {
      return res.status(400).json({ error: "Video URL is required for mediaType 'video'!" });
    }
  
    try {
      let url;
  
      if (mediaType === "image" && req.file) {
        url = `/uploads/image/${req.file.filename}`;
      } else if (mediaType === "video" && videoURL) {
        url = videoURL;
      }
  
      const newMedia = new media({
        type: mediaType,
        title,
        description,
        url,
      });
  
      await newMedia.save();
      res.status(201).json({ message: "Media saved successfully!", media: newMedia });
    } catch (error) {
      console.error("Error saving media:", error);
      res.status(500).json({ error: "Failed to save media!" });
    }
  });
  
//===============================================================================IMAGE GET==============================================================

  app.get('/media/upload', async (req, res) => {
    try {
        const getmedia = await media.find();
        res.status(200).json( getmedia );
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch media!' });
    }
});

//===============================================================================IMAGE PUT==============================================================

app.put("/media/upload/:id", upload.single("mediaFile"), async (req, res) => {
    const { id } = req.params;
    const { title, description, mediaType, url } = req.body;
  
    try {
      const existingMedia = await media.findById(id);
      if (!existingMedia) {
        return res.status(404).json({ message: "Media not found" });
      }
  
      existingMedia.title = title || existingMedia.title;
      existingMedia.description = description || existingMedia.description;
      existingMedia.mediaType = mediaType || existingMedia.mediaType;
  
      if (mediaType === "video") {
        existingMedia.url = url || existingMedia.url;
      } else if (mediaType === "image") {
        if (req.file) {
          existingMedia.url = req.file.filename; 
        } else {
          existingMedia.url = url || existingMedia.url;
        }
      }
  
      await existingMedia.save();
      res.status(200).json({ message: "Media updated successfully" });
    } catch (error) {
      console.error("Error updating:", error);
      res.status(500).json({ message: "Failed to update", error });
    }
  });
  
//===============================================================================IMAGE DELETE==============================================================

app.delete("/media/upload/:id", async(req,res) => {
    const deletemedia = await media.findByIdAndDelete(req.params.id);
    
    if(!deletemedia){
        return res.status(404).json({
            message : "Media not found"
        })
    }
    res.json({
        message : "Department Deleted Successfully",
        deletemedia
    });
});


//==============================================================================X-X-X=================================================================================================================================================================================================================================================================
//======================================================================== X-X-X END X-X-X ===========================================================================================================================================================================================================================================================
//==============================================================================X-X-X=================================================================================================================================================================================================================================================================