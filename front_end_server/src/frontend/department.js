import React, {useState, useEffect } from 'react';
import * as XLSX from 'xlsx';
import { Button, Pagination, Modal } from 'flowbite-react';
import { HiOutlineExclamationCircle } from "react-icons/hi";
import { HiHome } from "react-icons/hi";
import { HiEye, HiEyeOff } from "react-icons/hi";
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Qdepartment = () => {

    const [location, setlocation] = useState([]);
    const [department, setdepartment] = useState([]);
    const [clickedlocation, setclickedlocation] =useState('');
    const [departmentname, setdepartmentname] = useState('');
    const [password, setpassword] = useState('');
    const [targetname, settargetname] = useState('');
    const [targetno, settargetno] = useState('');
    const [targetpos, settargetpos] = useState('');
    const [editdepartment, seteditdepartment] = useState(null);
    const [iscreating, setiscreating] = useState(false);
    const [search, setsearch] = useState('');
    const [showpassword, setshowpassword] = useState(false);
    const [currentPage, setCurrentPage] = useState(1); 
    const [itemsPerPage, setItemsPerPage] = useState(10); 
    const [showcreatemodal, setshowcreatemodal] = useState(false);
    const [showupdatemodal, setshowupdatemodal] = useState(false);
    const [showdeletemodal, setshowdeletemodal] = useState(false);
    const [deleteid, setdeleteid] = useState(null);
    const [showcancelmodal, setshowcancelmodal] = useState(false);

    const backendbaseurl = process.env.REACT_APP_NODE_BACKEND_BASEURL
    

    useEffect(() => {
        getlocation();
        getdepartment();
    },[])

    //***********************************Listing Locations*************************************

    const getlocation = async() => {
        const response = await fetch(`${backendbaseurl}/locations`);
        const data = await response.json();
        console.log("Locations:", data);
        setlocation(data);
    };

    //***********************************ListingDepartments*************************************

    const getdepartment = async(locationid ='') => {
        const response = await fetch(locationid ? `${backendbaseurl}/departments?locationid=${locationid}` :`${backendbaseurl}/departments`);
        const data = await response.json();
        setdepartment(data);
    };

    const filterdepart = department.filter((dept) => {
        const searching = search.toLowerCase();
        return(
            dept.departmentname.toLowerCase().includes(searching) ||
            dept.targetname.toLowerCase().includes(searching) || 
            dept.targetno.toLowerCase().includes(searching)
        );
    })

    //***********************************Creating Departments*************************************

    const createdepartment = async () => {
        await fetch(`${backendbaseurl}/departments`, {
            method : 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ departmentname, password, locationid: clickedlocation, targetname, targetno, targetpos }),
        });
        clearbox();
        seteditdepartment(null);
        getdepartment(clickedlocation);
        setshowcreatemodal(false);
        toast.success("Department Created successfully");
    };

    //***********************************Updating Locations*************************************

    const updatedepartment = async () => {
        await fetch(`${backendbaseurl}/departments/${editdepartment._id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                departmentname: departmentname,
                password: password,
                targetname: targetname,
                targetno: targetno,
                targetpos: targetpos,
                locationid: clickedlocation,
            }),
        });
        clearbox();
        seteditdepartment(null);
        getdepartment(clickedlocation);
        setshowupdatemodal(false);
        toast.success("Department Updated successfully");
    };

    //***********************************Deleting Locations*************************************

    const deletedepartment = async (id) => {
        await fetch(`${backendbaseurl}/departments/${id}`, {
            method: 'DELETE',
        });
        getdepartment(clickedlocation);
        setshowdeletemodal(false);
        toast.success("Department Deleted successfully");
    };

    //***********************************Setting of depart values*************************************

    const updatedepart = (department) => {
        seteditdepartment(department);
        setdepartmentname(department.departmentname);
        setpassword(department.password);
        settargetname(department.targetname);
        settargetno(department.targetno);
        settargetpos(department.targetpos);
    };

    //**********************************Clearing depart values*************************************

    const clearbox = () => {
        setdepartmentname('');
        setpassword('');
        settargetname('');
        settargetno('');
        settargetpos('');
    };

    const locationclicked = (change) => {
        setclickedlocation(change.target.value);
        getdepartment(change.target.value);
        clearbox();
        seteditdepartment(null);
    };

    const handleCancel = () => {
        clearbox();
        setiscreating(false); 
        seteditdepartment(null);
        setshowcancelmodal(false);
        toast.error("Progress canceled");
    };


    const makedisable = () => {
        return !clickedlocation || clickedlocation === ''; 
    };

    const handleCreate = () => {
        setiscreating(true); 
        clearbox(); 
    };

    // const handleCancelCreate = () => {
    //     setiscreating(false); 
    //     clearbox(); 
    // };

    const exportToExcel = () => {
        if (filterdepart.length === 0) {
          alert("No data to export!");
          return;
        }
      
        
        const worksheet = XLSX.utils.json_to_sheet(filterdepart);
      
       
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "Forms");
      
        
        XLSX.writeFile(workbook, "FilteredForms.xlsx");
        toast.info("Exported successfully");
      };

    const showthepassword = () => {
        setshowpassword((prepassstate) => !prepassstate)
    };

    const handlePaginationChange = (page) => {
        setCurrentPage(page);
      };

    const handleItemsPerPageChange = (e) => {
        setItemsPerPage(Number(e.target.value)); 
        setCurrentPage(1); 
    };

    const currentForms = filterdepart.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

    const modelcreate = () => {
        setshowcreatemodal(true);
    };

    const modellupdate = () => {
        setshowupdatemodal(true);
    };

    const modeldelete = (id) => {
        setdeleteid(id);
        setshowdeletemodal(true);
    };

    const modelcancel = () => {
        setshowcancelmodal(true);
    }

    return(
        <div class="outer1box">
           <div class="outerheader"> 
                <div className="m-11 flex w-full">
                    <div className='flex flex-col gap-2' >
                    <h2 class=" font-semibold text-3xl text-white">Department Page</h2> 
                    <div className="flex items-center space-x-2">
                            <a href="/department" className="text-slate-200 hover:text-white flex items-center">
                                <HiHome className="mr-1" />
                                Home
                            </a>
                            <span className="text-slate-200">/</span>
                            <span className="text-slate-200 hover:text-white">Department</span>
                        </div>
                     </div>

                    <button onClick={exportToExcel} 
                    class="animate-bounce h-16 drop-shadow-lg gap-2 shadow-blue-500  text-white bg-blue-500 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-base px-5 py-2.5 text-center inline-flex items-center me-2 ml-auto" >
                    Export
                    <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg" class="animate-bounce hover:animate-spin">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M2 12C2 7.28595 2 4.92893 3.46447 3.46447C4.92893 2 7.28595 2 12 2C16.714 2 19.0711 2 20.5355 3.46447C22 4.92893 22 7.28595 22 12C22 16.714 22 19.0711 20.5355 20.5355C19.0711 22 16.714 22 12 22C7.28595 22 4.92893 22 3.46447 20.5355C2 19.0711 2 16.714 2 12ZM12 6.25C12.4142 6.25 12.75 6.58579 12.75 7V12.1893L14.4697 10.4697C14.7626 10.1768 15.2374 10.1768 15.5303 10.4697C15.8232 10.7626 15.8232 11.2374 15.5303 11.5303L12.5303 14.5303C12.3897 14.671 12.1989 14.75 12 14.75C11.8011 14.75 11.6103 14.671 11.4697 14.5303L8.46967 11.5303C8.17678 11.2374 8.17678 10.7626 8.46967 10.4697C8.76256 10.1768 9.23744 10.1768 9.53033 10.4697L11.25 12.1893V7C11.25 6.58579 11.5858 6.25 12 6.25ZM8 16.25C7.58579 16.25 7.25 16.5858 7.25 17C7.25 17.4142 7.58579 17.75 8 17.75H16C16.4142 17.75 16.75 17.4142 16.75 17C16.75 16.5858 16.4142 16.25 16 16.25H8Z" fill="white"/>
                    </svg>
                    </button>
                </div>
           </div>

           <div class=" bg-cyan-100  items-end rounded-lg p-10 gap-6 shadow-lg shadow-teal-200 border hover:bg-cyan-200 transition-all ease-in-out">
                
                <div class="flex flex-col">
                   
                    <div class="flex items-end">

                { /***********************************Headers*************************************/}

                    <div class="dropdownone">
                        <label class = "dropdownlabel">Choose Location</label>
                        <select value={clickedlocation} onChange={locationclicked} class="dropdownbutton"> 
                            <option value = '' class="dropdownoption">All Location</option>
                            {location.map(location => (
                                <option key={location._id} value={location._id} class="dropdownoption" >{location.locationname}</option>
                            ))}
                        </select>
                    </div>

                    <div className="flex  items-center rounded-xl  ml-8 text-gray-700">
                        <label htmlFor="itemsPerPage" className="mr-2 text-lg font-medium">Show</label>
                        <select
                            id="itemsPerPage"
                            value={itemsPerPage}
                            onChange={handleItemsPerPageChange}
                            className="bg-white border border-gray-300 rounded p-2 focus:outline-none hover:cursor-pointer"
                        >
                            <option value={5}>5</option>
                            <option value={10}>10</option>
                            <option value={20}>20</option>
                            <option value={50}>50</option>
                        </select>
                        <label htmlFor="itemsPerPage" className="ml-2 text-lg font-medium">entrie</label>
                    </div> 

                    <div class="flex w-96 bg-white ml-10 px-3 rounded-lg items-center border border-gray-300 transition-all ease-in-out hover:border-blue-700 focus:border-gray-500 ">
                        <div className="text-gray-600">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" width="24" height="24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M11 4a7 7 0 1 1-4.95 11.95l-3.95 3.95a1 1 0 0 1-1.414-1.414l3.95-3.95A7 7 0 0 1 11 4z" />
                            </svg>
                        </div>
                        <input
                            type="text"
                            placeholder="Search by department name, person, or phone..."
                            value={search}
                            onChange={(e) => setsearch(e.target.value)}
                            class="block w-full p-4 text-sm text-gray-900  focus:outline-none"
                        />
                    </div>
                    </div>

                    <div class="m-auto">            
                    {(editdepartment || iscreating)&&(
                            < div className='flex ' >
                                <div className='depinputblock'>
                                <label className='dropdownlabel'>Department</label>
                                <input
                                    className='depinput'
                                    value={departmentname}
                                    onChange ={(e) => setdepartmentname(e.target.value)}
                                    placeholder='Department name'
                                    disabled={!!editdepartment}
                                    required
                                />
                            </div>

                            <div className='depinputblock'>
                                <label className='dropdownlabel'>Password</label>
                                <div className='flex bg-white p-3 rounded px-2 focus:border-gray-500 transition-all ease-in-out duration-300 h-10 w-56 hover:border-blue-500 border-2'>
                                    <input
                                            type={showpassword? "text" : "password"}
                                            value={password}
                                            onChange={(e) => setpassword(e.target.value)}
                                            placeholder="Department Password"
                                            className='outline-none'
                                            required
                                        />
                                        <div onClick={showthepassword} className=" cursor-pointer">
                                            {showpassword? (
                                                <HiEyeOff className="text-gray-500" size={24} />
                                            ):(
                                                <HiEye className="text-gray-500" size={24} />
                                            )
                                            }
                                        </div>
                            </div>
                           </div>
                           <form className='depinputblock'>
                                <label className='dropdownlabel'>Incharge Name</label>
                                <input
                                    className = 'depinput'
                                    value={targetname}
                                    onChange={(e) => settargetname(e.target.value)}
                                    placeholder="Person Name"
                                    required
                                />
                            </form>

                            <div className='depinputblock'>
                                <label className='dropdownlabel'>Phone</label>
                                <input
                                    type="tel"
                                    className = 'depinput'
                                    value={targetno}
                                    onChange={(e) => settargetno(e.target.value)}
                                    placeholder="Phone No"
                                    required
                                />
                            </div>
                            <div className='depinputblock'>
                                <label className='dropdownlabel'>Position</label>
                                <input
                                    className='depinput'
                                    value={targetpos}
                                    onChange={(e) => settargetpos(e.target.value)}
                                    placeholder="Position"
                                />
                            </div>
                            </div>
                            )}
                            </div>
                            <div class="flex m-auto mt-6 " >
                            {editdepartment ? (
                                    <>
                                        <button onClick={modellupdate} disabled={makedisable()} class = " create">Update</button>
                                        <button onClick={modelcancel} class=" cancel">Cancel</button>
                                    </>
                                ) :  iscreating ? (
                                    <>
                                        <button onClick={modelcreate} disabled={makedisable()} class = " create">
                                            Create
                                        </button>
                                        <button onClick={modelcancel} class=" cancel">Cancel</button>
                                    </>
                                ) : (
                                    <button onClick={handleCreate} class="addnew">Add Department
                                    <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg">
                                        <path fill-rule="evenodd" clip-rule="evenodd" d="M12 22C7.28595 22 4.92893 22 3.46447 20.5355C2 19.0711 2 16.714 2 12C2 7.28595 2 4.92893 3.46447 3.46447C4.92893 2 7.28595 2 12 2C16.714 2 19.0711 2 20.5355 3.46447C22 4.92893 22 7.28595 22 12C22 16.714 22 19.0711 20.5355 20.5355C19.0711 22 16.714 22 12 22ZM12 8.25C12.4142 8.25 12.75 8.58579 12.75 9V11.25H15C15.4142 11.25 15.75 11.5858 15.75 12C15.75 12.4142 15.4142 12.75 15 12.75H12.75L12.75 15C12.75 15.4142 12.4142 15.75 12 15.75C11.5858 15.75 11.25 15.4142 11.25 15V12.75H9C8.58579 12.75 8.25 12.4142 8.25 12C8.25 11.5858 8.58579 11.25 9 11.25H11.25L11.25 9C11.25 8.58579 11.5858 8.25 12 8.25Z" fill="white"/>
                                    </svg>
                                    </button>
                            )}
                            </div>
                    </div>

                    <Modal show={showcreatemodal} onClose={() => setshowcreatemodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                        <Modal.Header class = "bg-gray-600 text-white"></Modal.Header>
                        <Modal.Body class="bg-gray-600">
                        <div className="text-center  m-aut0 bg-gray-600">
                          <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                          <h3 className="mb-5 text-lg font-normal text-white">
                            Are you sure you want to create Department?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            <button className='create' onClick={createdepartment}>
                              Create
                            </button>
                            <Button class="delete" onClick={() => setshowcreatemodal(false)}>
                              cancel
                            </Button>
                          </div>
                        </div>
                        </Modal.Body>
                    </Modal>

                    <Modal show={showupdatemodal} onClose={() => setshowupdatemodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                        <Modal.Header class = "bg-gray-600 text-white"></Modal.Header>
                        <Modal.Body class="bg-gray-600">
                        <div className="text-center  m-aut0 bg-gray-600">
                          <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                          <h3 className="mb-5 text-lg font-normal text-white">
                            Are you sure you want to update Department?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            <button className='create' onClick={updatedepartment}>
                              Update
                            </button>
                            <Button color="gray" onClick={() => setshowupdatemodal(false)}>
                              cancel
                            </Button>
                          </div>
                        </div>
                        </Modal.Body>
                    </Modal>

                    <Modal show={showdeletemodal} onClose={() => setshowdeletemodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                        <Modal.Header class = "bg-gray-600 text-white">Confirm Delete</Modal.Header>
                        <Modal.Body class="bg-gray-600">
                        <div className="text-center  m-aut0 bg-gray-600">
                          <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                          <h3 className="mb-5 text-lg font-normal text-white">
                            Are you sure you want to Delete?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            <button className='delete' onClick={()=> deletedepartment(deleteid)}>
                              Delete
                            </button>
                            <Button color="gray" onClick={() => {setshowdeletemodal(false); (toast.error("Progress Canceled"))}}>
                              Cancel
                            </Button>
                          </div>
                        </div>
                        </Modal.Body>
                    </Modal>

                    <Modal show={showcancelmodal} onClose={() => setshowcancelmodal(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                        <Modal.Header class = "bg-gray-600 text-white"></Modal.Header>
                        <Modal.Body class="bg-gray-600">
                        <div className="text-center  m-aut0 bg-gray-600">
                          <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                          <h3 className="mb-5 text-lg font-normal text-white">
                            Are you sure you want to cancel progress?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            <button className='delete' onClick={handleCancel}>
                              Yes
                            </button>
                            <button className='create' onClick={() => setshowcancelmodal(false)}>
                              No
                            </button>
                          </div>
                        </div>
                        </Modal.Body>
                    </Modal>




                    { /***********************************Listing Departments*************************************/}
                    
                    <div class="tableout">
                    <table class="table ">
                            <thead class= " tablehead">
                                <tr class="px-6 py-3">
                                    <th class="tc">S.no</th>
                                    <th class="tc">Department</th>
                                    <th class="tc">Person Nmae</th>
                                    <th class="tc">Position</th>
                                    <th class="tc">Phone</th>
                                    <th class="tc">Password</th>
                                    <th class="tc text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {currentForms.map((department, index) => (
                                <tr key={department.departmentname} class={`h-10 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-100'} hover:bg-gray-300 text-base`}>
                                    <td class="tc">{index+1}</td>
                                    <td class="tc">{department.departmentname}</td>
                                    <td class="tc">{department.targetname}</td>
                                    <td class="tc">{department.targetpos}</td>
                                    <td class="tc">{department.targetno}</td>
                                    <td class="tc">{department.password}</td>
                                    <td class="tc">
                                     <div className='flex justify-center gap-4'>
                                        <button onClick={() => updatedepart(department)} className='update'>Update
                                        <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M20.9888 4.28491L19.6405 2.93089C18.4045 1.6897 16.4944 1.6897 15.2584 2.93089L13.0112 5.30042L18.7416 11.055L21.1011 8.68547C21.6629 8.1213 22 7.33145 22 6.54161C22 5.75176 21.5506 4.84908 20.9888 4.28491Z" fill="white"/>
                                            <path d="M16.2697 10.9422L11.7753 6.42877L2.89888 15.3427C2.33708 15.9069 2 16.6968 2 17.5994V21.0973C2 21.5487 2.33708 22 2.89888 22H6.49438C7.2809 22 8.06742 21.6615 8.74157 21.0973L17.618 12.1834L16.2697 10.9422Z" fill="white"/>
                                        </svg>
                                        </button>
                                        <button onClick={() => modeldelete(department._id)} className='delete'>Delete
                                            <svg 
                                                fill="white" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlnsXlink="http://www.w3.org/1999/xlink" width="23px" height="23px" viewBox="0 0 89.312 89.312" xmlSpace="preserve">
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
                                        </button>
                                        </div>
                                    </td>
                                </tr>
                                ))}
                            </tbody>
                    </table>
                    </div>
                <div className="mt-4 flex justify-center  ">

            <Pagination className="bg-green-300 rounded-lg"
            currentPage={currentPage}
            totalPages={Math.ceil(filterdepart.length / itemsPerPage)}
            onPageChange={handlePaginationChange}
            />
                </div>

            </div>
        </div>
    );

};

export default Qdepartment;


//*************************************************************END OF DEPARTMENTS********************************************************************