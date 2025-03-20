import React, {useState, useEffect} from 'react';
import { Button, Modal} from "flowbite-react";
import { HiHome,HiOutlineExclamationCircle } from "react-icons/hi";
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Qlocation = () => {

    const [location, setlocation] = useState([]);
    const [locationname, setlocationname] = useState('');
    const [editlocation, seteditlocation] = useState(null);
    const [confirmcreate, setconfirmcreate] = useState(false);
    const [showcreatemodal, setshowcreatemodal] = useState(false);
    const [showdeletemodal, setshowdeletemodal] = useState(false);
    const [deleteid, setdeleteid] = useState(null);   
    
    const backendbaseurl = process.env.REACT_APP_NODE_BACKEND_BASEURL
    
    useEffect(() => {
        getlocation();
    },[]);
    
    // ***********************************Location Fetching*************************************

    const getlocation = async () =>{
        const response = await fetch(`${backendbaseurl}/locations`);
        const responseddata = await response.json();
        setlocation(responseddata);
    };

     // ***********************************Create Location*************************************

    const createlocation = async () => {
        await fetch(`${backendbaseurl}/locations`, {
            method : "POST",
            headers : {
                'content-type' : 'application/json',
            },
            body : JSON.stringify({ locationname : locationname}),
        });
        setlocationname('');
        getlocation();
        setconfirmcreate(false);
        setshowcreatemodal(false);
        toast.success("Location Created successfully");
    };
     // ***********************************Updating Location*************************************

    const updatelocation = async (id) => {
        await fetch(`${backendbaseurl}/locations/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ locationname: editlocation.name }),
        })
        seteditlocation(null);
        getlocation();
        toast.success("Location Updated successfully");
    };

     // ***********************************Deleting Location*************************************

    const deletelocation = async (id) => {
        await fetch(`${backendbaseurl}/locations/${id}`,{
            method : "DELETE",
        });
        getlocation();
        setshowdeletemodal(false);
        toast.success("Location Deleted successfully");
    };

    const creationconfirm = async () => {
        setconfirmcreate(true);
    }

    const modelcreate = () => {
        setshowcreatemodal(true);
    };

    const modeldelete = (id) => {
        setdeleteid(id);
        setshowdeletemodal(true);
    };

     // *************************************Location Listing*************************************

    return(
        <div className='outer1box' >
            <div className='outerheader'>
                <div className="m-11 flex w-full">
                    <div className='flex flex-col gap-2'>
                        <h2 class=" font-semibold text-3xl text-white">Location Page</h2> 
                        <div className="flex items-center space-x-2 ">
                            <a href="/location" className="text-slate-200 hover:text-white flex items-center">
                                <HiHome className="mr-1" />
                                Home
                            </a>
                            <span className="text-slate-200">/</span>
                            <span className="text-slate-200 hover:text-white">Location</span>
                        </div>
                    </div>
                </div>
            </div>

            <Modal show={showcreatemodal} onClose={() => setshowcreatemodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                <Modal.Header class = "bg-gray-600 text-white"></Modal.Header>
                <Modal.Body class="bg-gray-600">
                <div className="text-center  m-aut0 bg-gray-600">
                    <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                    <h3 className="mb-5 text-lg font-normal text-white">
                    Are you sure want to create Location?
                    </h3>
                    <div className="flex justify-center gap-4 mb-10 ">
                    <button className='create' onClick={createlocation}>
                         Create
                    </button>
                    <Button color="gray" onClick={() => setshowcreatemodal(false)}>
                         cancel
                    </Button>
                    </div>
                </div>
                </Modal.Body>
            </Modal>

            <Modal show={showdeletemodal} onClose={() => setshowdeletemodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                <Modal.Header class = "bg-gray-600 text-white"></Modal.Header>
                <Modal.Body class="bg-gray-600">
                <div className="text-center  m-aut0 bg-gray-600">
                    <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                    <h3 className="mb-5 text-lg font-normal text-white">
                    Are you sure want to delete Location?
                    </h3>
                    <div className="flex justify-center gap-4 mb-10 ">
                    <Button color="failure" onClick={() => deletelocation(deleteid)}>
                        Delete
                    </Button>
                    <Button color="gray" onClick={() => setshowdeletemodal(false)}>
                        cancel
                    </Button>
                    </div>
                </div>
                </Modal.Body>
            </Modal>

            

            

            {/*  ************************************Creating and editing********************************** */}

            <div class=" bg-cyan-100  items-end rounded-lg p-10 gap-6 shadow-lg shadow-teal-200 border hover:bg-cyan-200 transition-all ease-in-out">
                <div className='flex gap-6 items-end'>
                    <button onClick={creationconfirm}  class="addnew" >Add Location
                    <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M12 22C7.28595 22 4.92893 22 3.46447 20.5355C2 19.0711 2 16.714 2 12C2 7.28595 2 4.92893 3.46447 3.46447C4.92893 2 7.28595 2 12 2C16.714 2 19.0711 2 20.5355 3.46447C22 4.92893 22 7.28595 22 12C22 16.714 22 19.0711 20.5355 20.5355C19.0711 22 16.714 22 12 22ZM12 8.25C12.4142 8.25 12.75 8.58579 12.75 9V11.25H15C15.4142 11.25 15.75 11.5858 15.75 12C15.75 12.4142 15.4142 12.75 15 12.75H12.75L12.75 15C12.75 15.4142 12.4142 15.75 12 15.75C11.5858 15.75 11.25 15.4142 11.25 15V12.75H9C8.58579 12.75 8.25 12.4142 8.25 12C8.25 11.5858 8.58579 11.25 9 11.25H11.25L11.25 9C11.25 8.58579 11.5858 8.25 12 8.25Z" fill="white"/>
                    </svg>
                    </button>

                    {confirmcreate && 
                    <div className='flex items-end'>
                        <div  className='depinputblock'>
                            <label className='dropdownlabel'>Location Name</label>
                            <input
                                value = {locationname}
                                onChange={(a) => setlocationname(a.target.value)}
                                placeholder="Location Name"
                                className='depinput'
                            />
                        </div>
                        <button onClick={modelcreate} className='create'>Add Location</button>
                        <button onClick={() => setconfirmcreate(false)} className='cancel'>Cancel</button>
                    </div>
                    }
                </div>

             {/*  ***********************************Listing Locations************************************* */}


             <div class="tableout ">
                <table class="table">
                    <thead class= "tablehead ">
                        <tr class="px-6 py-3 ">
                            <th class="tc">S.no</th>
                            <th class="tc">Location Name</th>
                            <th class="tc">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {location.map((locations, index) => (
                            <tr key={locations._id} class={`h-10 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-100'} hover:bg-gray-300 text-base`}>
                                {editlocation?.id === locations._id ? (
                                    <>
                                    <input
                                    value={editlocation.name}
                                    onChange={(e) =>
                                        seteditlocation({ ...editlocation, name: e.target.value })
                                    }
                                    />
                                    <button onClick={() => updatelocation(locations._id)}>Save</button>
                                </>):
                                (
                                
                                <>
                                    <td class="tc">{index + 1}</td>
                                    <td class="tc">{locations.locationname}</td>
                                    <td class="tc">{/* <button onClick={() => seteditlocation({ id : locations._id, name : locations.locationname})}>Update</button> */}
                                    <button onClick={() => modeldelete(locations._id)} className='delete'>Delete
                                    <svg 
                    fill="white"
                    version="1.1"
                    id="Capa_1"
                    xmlns="http://www.w3.org/2000/svg"
                    xmlnsXlink="http://www.w3.org/1999/xlink"
                    width="23px"
                    height="23px"
                    viewBox="0 0 89.312 89.312"
                    xmlSpace="preserve">
                    <g>
                      <path d="M71.519,15.681v-0.44c0-2.188-1.773-3.96-3.961-3.96h-9.627c0.023-0.009,0.039-0.018,0.064-0.026
                        c2.213-0.728,0.77-0.764,0.77-0.764L51.72,3.393L47.964,3.82c0,0-0.184,1.97-1.42,2.983c-0.188,0.155-0.318,0.314-0.426,0.475
                        c0.059-0.167-0.455-0.181-0.455-0.181L38.62,0l-3.758,0.428c0,0-0.184,1.97-1.418,2.983C32.21,4.424,32.917,5.66,32.917,5.66
                        l-1.395,1.384l0.863,0.871c0,0-1.826,1.795-2.145,3.365h-2.77c0.822-2.003,0.711-5.785,0.711-5.785s-3.457,1.734-2.414-0.35
                        c1.041-2.084,0-1.084,0-1.084h-10l-2.344,2.968c0,0,1.27,1.518,1.119,3.108c-0.047,0.494,0.061,0.858,0.221,1.143H9.476
                        c-2.186,0-3.959,1.772-3.959,3.96v0.44c0,2.188,1.773,6.271,3.959,6.271h2.521l3.367,64.857c0.074,1.404,1.232,2.505,2.637,2.505
                        H59.36c1.41,0,2.569-1.107,2.637-2.517L65.06,21.95h2.496C69.745,21.951,71.519,17.868,71.519,15.681z M44.894,7.861
                        c0.792-0.261,1.113-0.432,1.201-0.545c-0.555,0.875-0.078,1.736-0.078,1.736L45.556,9.51C44.622,9.097,43.378,8.361,44.894,7.861z
                        M45.155,10.974l0.305,0.307h-0.648C44.931,11.176,45.046,11.073,45.155,10.974z M25.935,59.21c-1.566,0.911-2.244-0.49-2.244-0.49
                        c-0.168-0.78-0.262-1.59-0.262-2.425c0-5.973,4.514-10.84,10.115-10.99l-3.953-2.604c-0.75-0.495-0.98-1.538-0.514-2.332
                        c0.465-0.797,1.451-1.039,2.197-0.546l6.816,4.489c0.359,0.237,0.615,0.615,0.711,1.053c0.096,0.437,0.025,0.897-0.199,1.279
                        l-4.234,7.227c-0.301,0.516-0.822,0.8-1.355,0.8c-0.289,0-0.578-0.082-0.842-0.255c-0.75-0.494-0.979-1.537-0.514-2.333l1.99-3.397
                        c-3.889,0.09-7.025,3.465-7.025,7.609c0,0.395,0.037,0.773,0.092,1.15C26.714,57.445,27.073,58.613,25.935,59.21z M46.481,67.688
                        c-0.565,0.563-1.195,1.08-1.896,1.532c-5.021,3.234-11.561,2.076-14.719-2.552l-0.047,4.734c-0.012,0.896-0.762,1.656-1.684,1.694
                        c-0.92,0.039-1.658-0.657-1.648-1.554l0.082-8.16c0.006-0.432,0.186-0.852,0.5-1.17c0.316-0.314,0.742-0.507,1.184-0.525
                        l8.369-0.353c0.596-0.026,1.119,0.258,1.406,0.706c0.156,0.242,0.244,0.531,0.24,0.845c-0.01,0.897-0.762,1.656-1.682,1.695
                        l-3.936,0.168c2.182,3.221,6.719,4.028,10.205,1.784c0.328-0.213,0.629-0.45,0.916-0.699c0,0,0.787-0.936,1.906-0.303
                        C47.292,66.357,46.481,67.688,46.481,67.688z M56.54,58.376l-6.814,4.487c-0.361,0.235-0.809,0.321-1.25,0.236
                        c-0.439-0.085-0.834-0.33-1.096-0.688l-4.965-6.745c-0.355-0.479-0.412-1.072-0.201-1.563c0.115-0.265,0.307-0.498,0.568-0.672
                        c0.75-0.492,1.799-0.292,2.346,0.45l2.334,3.172c1.455-3.608-0.406-7.823-4.215-9.463c-0.359-0.155-0.725-0.271-1.092-0.37
                        c0,0-1.215-0.131-1.314-1.412c-0.217-1.799,1.34-1.869,1.34-1.869c0.783,0.156,1.563,0.389,2.328,0.718
                        c5.488,2.362,8.176,8.432,6.102,13.636l3.953-2.604c0.75-0.492,1.801-0.291,2.346,0.45C57.456,56.883,57.29,57.885,56.54,58.376z
                        M58.679,25.001H17.843l-0.559-3.05h42.493L58.679,25.001z M83.796,80.906c0,0-2.975,3.131-5.008,3.711s-0.445,1.897-0.445,1.897
                        l-1.607-0.377l-0.973,0.722l-0.854-1.15c0,0-3.551-0.146-6.301-1.479S69.835,79,69.835,79l-0.863-0.871l1.395-1.384
                        c0,0-0.707-1.235,0.527-2.249s1.418-2.983,1.418-2.983l3.758-0.428l7.043,7.098c0,0,1.445,0.036-0.77,0.765
                        C80.13,79.674,83.796,80.906,83.796,80.906z"/>
                    </g>
                    </svg>
                                        </button></td>
                                </>
                                )}
                            </tr>
                        ))}
                    </tbody>
                </table>
             </div>
            </div>
        </div>
    );
}; 

export default Qlocation;


//****************************************************END OF LOCATION PROCESS*****************************************************************************