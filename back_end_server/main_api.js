const express = require("express");
const app = express();
const bcrypt = require("bcrypt");
const mongoose = require("mongoose");
const multer = require("multer");
const path = require("path");
const jwt = require('jsonwebtoken');
const cors = require("cors");
app.use(express.json());
app.use(cors());

const fs = require('fs');


// Ensure that the directories exist
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

// Call this function when your server starts
createUploadDirs();


//Collection Files
const depart = require("./collectin_db/department.js");
const locat = require("./collectin_db/location.js");
const form = require("./collectin_db/form.js");
const resform = require("./collectin_db/responseform.js");
const media = require("./collectin_db/media.js");

//Server Connection
app.listen(4000, () => { console.log("Server connected in 4000 port")});

//Monodb Connection
mongoose.connect("mongodb://localhost:27017/quality_dept").then(() => { console.log("Mongodb Connected Successfully"); }).catch((err) => { console.error("Mongodb Connection failed", err); });

const JWT_SECRET = 'ghfjdghdxjgfhjxg';

//File Upload STorage
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

/* *****************************************************************************Server API Methods****************************************************************************/

                                                  /*******************************Location APIs******************************/

// Post Method For location
app.post('/locations', async (req, res) => {
    const { locationname } = req.body;
    try {
        const createlocation = new locat({ locationname });
    await createlocation.save();
    res.json(createlocation);
    } catch (error) {
        console.log("Error creating lcation", error);
    }
  });
  
  // Get Mehod For Location
  app.get('/locations', async (req, res) => {
    const getlocations = await locat.find();
    res.json(getlocations);
  });
  
  // Update Method For Location
  app.put('/locations/:id', async (req, res) => {
    const { locationname } = req.body;
    const updatelocation = await locat.findByIdAndUpdate(req.params.id, { locationname }, { new: true });
    res.json(updatelocation);
  });
  
  // Delete Method For Location
  app.delete('/locations/:id', async (req, res) => {
    await locat.findByIdAndDelete(req.params.id);
    res.json({ message: 'Location deleted' });
  });




                                                   /*******************************Depart APIs******************************/

// Post Method for Departmnt 
app.post("/departments", async(req, res) => {
    const {locationid, departmentname, targetname, targetpos, targetno, password} = req.body;
    
    try {
        const newdepart = new depart({locationid, departmentname, targetname, targetpos, targetno, password});
    await newdepart.save();
    res.json({
        message : "Department created!",
        newdepart
    });
    } catch (error) {
        console.log("Error", error)
    }
});

// Get Method for Department 
app.get("/departments", async(req, res) => {
    const { locationid } = req.query;
    let query = {};
    if (locationid) {
        query.locationid = locationid; 
    }
    const getdepart = await depart.find(query).populate('locationid', 'locationname');
    res.json(getdepart);
});


app.get("/departments/:id", async (req, res) => {
    try {
        const formid = req.params.id;
        const resforms = await depart.find({locationid : formid});

        if (!resforms) {
            return res.status(404).json({ error: 'Responsed form is not found'});
          }
        res.status(200).json(resforms);

    } catch (error) {
        console.error("Error showing responde deepview:",error);
        res.status(500).json({
            error : "Error showing responde deepview"
        });
    }
});

// Get Method for particular Department 

app.get("/form", async (req, res) => {
    const { fromdepartment, todepartment, locationid } = req.query;

    const query = {};
    
    if (locationid) {
        query.locationid = locationid;
    }
    
    if (fromdepartment && todepartment) {
        query.$or = [
            { fromdepartment },
            { todepartment },
        ];
    } else if (fromdepartment) {
        query.fromdepartment = fromdepartment;
    } else if (todepartment) {
        query.todepartment = todepartment;
    }

    try {
        const forms = await form.find(query);
        console.log("Fetched Forms Query:", query, "Forms:", forms);
        res.status(200).json(forms);
    } catch (error) {
        console.error("Error fetching forms:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});









// Put Method for Department
app.put("/departments/:id", async(req, res) => {
    const {locationid, departmentname, targetname, targetno, password} = req.body;
    const updatedepart = await depart.findByIdAndUpdate(req.params.id, { departmentname, targetname, targetno, password, locationid }, { new: true });
    await updatedepart.save();
    res.json({
        message : "Department updated Successfully",
        updatedepart
    });
});

// Delete method for Department
app.delete("/departments/:id", async(req,res) => {
    const deletedepart = await depart.findByIdAndDelete(req.params.id);
    
    if(!deletedepart){
        return res.status(404).json({
            message : "Department not found"
        })
    }
    res.json({
        message : "Department Deleted Successfully",
        deletedepart
    });
});

                                                    /*******************************Login APIs******************************/

// POST method for App Login

app.post("/applogin", async(req, res) => {
    const{locationid, _id, password} = req.body;
    console.log(req.body);

    try {
        const getlocation = await locat.findById(locationid);
        
        if (!getlocation) {
            return res.status(400).json({ message: 'Invalid location' });
        }
        
        const getdepartment = await depart.findOne({ locationid, _id });
        
        if (!getdepartment) {
            return res.status(400).json({ message: 'Invalid department' });
        }

        if (password !== getdepartment.password) {
            return res.status(400).json({ message: 'Incorrect password' });
        }
        

        const token = jwt.sign({ departmentId: getdepartment._id, locationId: getdepartment.locationid }, JWT_SECRET, {expiresIn: '30d'});

        if (!locationid || !_id || !password) {
            return res.status(400).send('Missing fields');
          }

        return res.json({ message: 'Login successful', token, getdepartment, getlocation});
    } catch (error) {
        return res.status(500).json({ message: 'Server error', error });
        
    }
});


// POST method for App form Submit

app.post("/form", async (req, res) => {
    const {fromdepartment,
           todepartmentid, 
           todepartment,
           departmentname, 
           locationname,
           locationid,
           subject, 
           description, 
           clinical,
           operatinal, 
           patimpact,
           finimpact,
           severity,
           personsinvolved,
           targetno,
           targetname
        } = req.body;

    try {
        const newform = new form({fromdepartment, 
                                  todepartmentid,
                                  todepartment, 
                                  departmentname,
                                  locationname,
                                  locationid,
                                  subject, 
                                  description, 
                                  clinical, 
                                  operatinal,
                                  patimpact,
                                  finimpact,
                                  severity,
                                  personsinvolved, 
                                  status: "Pending",
                                  opened: false,
                                  targetno,
                                  targetname
                                });
        await newform.save();
        res.status(201).json(newform);
    } catch (error) {
        res.status(500).json({ message: 'Error creating form', error });
    }
});

//Get method form




 // Delete Method For Form

 app.delete('/form/:id', async (req, res) => {
    await form.findByIdAndDelete(req.params.id);
    res.json({ message: 'Form deleted' });
  });

// POST method for App resform Submit

app.post("/response", async (req, res) => {
    try {
        
        const {
            reqformid,
            explanation,
            causes,
            isprevented,
            notprereason,
            futurepreaction,
            immediate,
            actiontype,
            resofimple,
            capa
        } = req.body;

        const response = new resform({
            reqformid,
            explanation,
            causes,
            isprevented,
            notprereason : isprevented? notprereason : undefined,
            futurepreaction,
            immediate,
            actiontype,
            resofimple,
            capa,
            createdtime: new Date()
        });
        const postedform = await response.save();
        await form.findByIdAndUpdate(reqformid, { status: "Completed" });
        res.status(201).json({ message: "Response submitted and form status changed" ,postedform});
    } catch (error) {
        console.error("Error submitting response form:", error);
        res.status(500).json({ error: "Failed to submit response form." });
    }
});

//Get method for responded form

app.get("/respondiew/:resid", async (req, res) => {
    try {
        const formid = req.params.resid;
        const resforms = await resform.findOne({reqformid : formid});

        if (!resforms) {
            return res.status(404).json({ error: 'Responsed form is not found'});
          }
        res.status(200).json(resforms);

    } catch (error) {
        console.error("Error showing responde deepview:",error);
        res.status(500).json({
            error : "Error showing responde deepview"
        });
    }
});



// GET method for all Received forms

app.get("/formsreceived/:departmentid", async(req, res) => {
    const { departmentid } = req.params;

    try {
        const getform = await form.find({ todepartment : departmentid }).sort({ createdtime: -1 }).exec();
        res.status(200).json(getform);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching all Received forms', error });
    }
});


// GET method for all Submitted forms

app.get('/formsubmitted/:departmentid', async (req, res) => {
    const { departmentid } = req.params;
  
    try {
      const forms = await form.find({ fromdepartment: departmentid }).sort({ createdtime: -1 }).exec();
      res.status(200).json(forms);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching submitted forms', error });
    }
});


// GET method for viewing form Details

app.get('/formdetails/:formid', async (req, res) => {
    const { formid } = req.params;
  
    try {
      const forms = await form.findById(formid);
      if (!forms) {
        return res.status(404).json({ message: 'Form not found' });
      }
      res.status(200).json(forms);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching form details', error });
    }
});



app.put('/opened/:formid', async (req, res) => {
    const { formid } = req.params;
    try {
      await form.findByIdAndUpdate(formid, { opened: true });
      res.status(200).send('Form marked as opened');
    } catch (err) {
      res.status(500).send('Error marking form as opened');
    }
  });
  

  //Media operation APIs

  const upload = multer({ storage });
  app.use("/upload", express.static(path.join(__dirname, "upload")));

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
  


  app.get('/media/upload', async (req, res) => {
    try {
        const getmedia = await media.find();
        res.status(200).json( getmedia );
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch media!' });
    }
});

app.put("/media/upload/:id", upload.single("mediaFile"), async (req, res) => {
    const { id } = req.params;
    const { title, description, mediaType, url } = req.body;
  
    try {
      const existingMedia = await media.findById(id);
      if (!existingMedia) {
        return res.status(404).json({ message: "Media not found" });
      }
  
      // Update fields
      existingMedia.title = title || existingMedia.title;
      existingMedia.description = description || existingMedia.description;
      existingMedia.mediaType = mediaType || existingMedia.mediaType;
  
      if (mediaType === "video") {
        // Update video URL
        existingMedia.url = url || existingMedia.url;
      } else if (mediaType === "image") {
        // Update image file
        if (req.file) {
          existingMedia.url = req.file.filename; // Save new file name
        } else {
          existingMedia.url = url || existingMedia.url; // Retain existing URL if no new file
        }
      }
  
      // Save changes
      await existingMedia.save();
      res.status(200).json({ message: "Media updated successfully" });
    } catch (error) {
      console.error("Error updating:", error);
      res.status(500).json({ message: "Failed to update", error });
    }
  });
  


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