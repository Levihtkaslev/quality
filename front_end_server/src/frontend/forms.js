import { useState, useEffect } from "react";
import axios from "axios";
import * as XLSX from 'xlsx';
import Datepicker from "react-tailwindcss-datepicker";
import { Button, Pagination, Modal } from 'flowbite-react';
import { HiOutlineExclamationCircle } from "react-icons/hi";
import { HiHome } from "react-icons/hi";
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';


const Mainform = () => {
  const [mforms, setmforms] = useState([]);
  const [choosed, setchoosed] = useState(null);
  const [showmore, setshowmore] = useState(false);
  const [location, setlocation] = useState([]);
  const [department, setdepartment] = useState([]);
  const [choosedloc, setchoosedloc] = useState(""); 
  const [chooseddep, setchooseddep] = useState(""); 
  const [choosedpen, setchoosedpen] = useState(""); 
  const [filterforms, setfilterforms] = useState([]);
  const [choosedUntouched, setchoosedUntouched] = useState(""); 
  const [responseform, setresponseform] = useState(null);
  const [subject, setsubject] = useState("");
  const [showdelete, setshowdelete] = useState(false);
  const [deleteid, setdeleteid] = useState("");
  const [dateRange, setDateRange] = useState({ startDate: null, endDate: null });
  const [currentPage, setCurrentPage] = useState(1); 
  const [itemsPerPage, setItemsPerPage] = useState(10); 

  const backendbaseurl = process.env.REACT_APP_NODE_BACKEND_BASEURL


  useEffect(() => {
    getforms();
    getlocation();
    
  }, []);

  const filteringForms = (loc, dep, pen, untouched, start, end, date) => {
    let updatedForms = mforms;
    console.log("Original Forms Data:", mforms);

    if (loc) {
      updatedForms = updatedForms.filter((form) => form.locationid === loc);
    }
    if (dep) {
      updatedForms = updatedForms.filter((form) => form.fromdepartment === dep);
    }
    if (pen) {
      updatedForms = updatedForms.filter((form) => form.status === pen);
    }
    if (untouched) {
        updatedForms = updatedForms.filter((form) => (untouched === "true" ? form.opened : !form.opened));

      }
    if (start && end) {
      updatedForms = updatedForms.filter((form) => {
        const formDate = new Date(form.createdtime).setHours(0, 0, 0, 0);
        const startDateOnly = new Date(start).setHours(0, 0, 0, 0);
        const endDateOnly = new Date(end).setHours(0, 0, 0, 0);
        return formDate >= startDateOnly && formDate <= endDateOnly;
      });
    }
    if(date){
      updatedForms =updatedForms.filter(
         (form) => form.subject.includes(date)
      )
  }
    
    console.log("Filtered Forms:", updatedForms);
    setfilterforms(updatedForms);
    
  };
  const handlePaginationChange = (page) => {
    setCurrentPage(page);
  };

  const handleItemsPerPageChange = (e) => {
    setItemsPerPage(Number(e.target.value)); 
    setCurrentPage(1); 
  };

  const handleDateChange = (newValue) => {
    setDateRange(newValue);
    filteringForms(
      choosedloc,
      chooseddep,
      choosedpen,
      choosedUntouched,
      newValue.startDate,
      newValue.endDate
    );
  };
  
  const clearfilter = () => {
    setchoosedpen("");
    setfilterforms("");
    setchoosedUntouched("");
    setresponseform("");
    setsubject("");
    setfilterforms(mforms);
    setDateRange({ startDate: null, endDate: null })
  }


  const exportToExcel = () => {
    if (filterforms.length === 0) {
      alert("No data to export!");
      return;
    }
    const worksheet = XLSX.utils.json_to_sheet(filterforms);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Forms");
    XLSX.writeFile(workbook, "FilteredForms.xlsx");
    toast.info("Exported successfully");
  };
  

  const dochoosedlocation = (e) => {
    const location = e.target.value;
    setchoosedloc(location);
    setchooseddep(""); 
    setchoosedpen(""); 
    setchoosedUntouched("");
    getdepartment(location);
    filteringForms(location, "", ""); 
  };

  const dochooseddepartment = (e) => {
    const department = e.target.value;
    setchooseddep(department);
    filteringForms(choosedloc, department, choosedpen); 
  };

  const dochoosedpending = (e) => {
    const status = e.target.value;
    setchoosedpen(status);
    filteringForms(choosedloc, chooseddep, status); 
  };

  const dochoosedUntouched = (e) => {
    const untouched = e.target.value;
    setchoosedUntouched(untouched);
    filteringForms(choosedloc, chooseddep, choosedpen, untouched); 
  };

  const handlesubject = (r) => {
    const jjj = r.target.value;
    setsubject(jjj);
    filteringForms(choosedloc, chooseddep, choosedpen, choosedUntouched,"","", jjj);
  };




  const getforms = async () => {
    try {
      const response = await axios.get(`${backendbaseurl}/form`);
      setmforms(response.data);
      setfilterforms(response.data);
    } catch (error) {
      console.log("Error getting forms: ", error);
    }
  };

  const getlocation = async () => {
    try {
      const response = await axios.get(`${backendbaseurl}/locations`);
      setlocation(response.data);
    } catch (error) {
      console.log("Error getting location", error);
    }
  };

  const getdepartment = async (location) => {
    try {
      const response = await axios.get(
        `${backendbaseurl}/departments?locationid=${location}`
      );
      setdepartment(response.data);
      console.log(response.data);
    } catch (error) {
      console.log("Error getting departments", error);
    }
  };
const confirmdelete = async (deleteid) => {
  try {
    await axios.delete(`${backendbaseurl}/form/${deleteid}`);
    getforms(); 
  } catch (error) {
    console.log("Error deleting form", error);
  }finally {
    closedelete();
  }
  toast.success("Form Deleted successfully");
};


  const openconfirm = (id) => {
    console.log("Opening delete confirmation for id:", id);
    setdeleteid(id);
    setshowdelete(true);
    console.log("showdelete status:", showdelete);
  }

  const closedelete = () => {
    setdeleteid(null)
    setshowdelete(false)
  }

const viewmore = async (form) => {
    setchoosed(form);
    setshowmore(true);
    const res = await fetch(`${backendbaseurl}/respondiew/${form._id}`)
    const ress = await res.json();
    if (ress) {
        setresponseform(ress);
      }
  };

  const closeall = () => {
    setshowmore(false);
    setchoosed(null);
  };

  const clipboard = (clip) => {
    navigator.clipboard.writeText(clip)
    toast.success("Copied successfully");
  };
  
  const currentForms = filterforms.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

  return (
    <div class="outer1box">
      
      <div className="outerheader">
          <div className="m-11">
          <div className='flex flex-col gap-2'>
          <h2 class=" font-semibold text-3xl text-white">Ticket Forms</h2> 
          <div className="flex items-center space-x-2">
              <a href="/forms" className="text-slate-200 hover:text-white flex items-center">
                  <HiHome className="mr-1" />
                  Home
              </a>
              <span className="text-slate-200">/</span>
              <span className="text-slate-200 hover:text-white">forms</span>
          </div>
          </div>
          </div>

        <div class="flex  items-center ml-auto pr-4 " >
        <div className="flex items-end justify-end">
       

            <div className="w-96 ">
            <label className="block  mt-2 mb-4 text-white">Range</label>
            <div className="relative">
              <Datepicker
                value={dateRange}
                containerClassName="relative mt-2"
                onChange={handleDateChange}
                showShortcuts={true} 
                useRange={true} 
                asSingle={false}
                inputClassName="w-full px-4 py-2 hover:cursor-pointer text-gray-500 border border-gray-300 rounded-lg  focus:outline-none focus:ring-2 focus:ring-blue-500 hover:border-blue-400 hover:shadow-teal-500 shadow-teal-300 hover:shadow-lg shadow-md transition-all ease-in-out duration-300"
                toggleClassName="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500"
              />
            </div>
            </div>


            <button onClick={exportToExcel} 
              class=" animate-bounce  h-16 drop-shadow-lg shadow-blue-500 gap-2 text-white bg-blue-500 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-base px-5 py-2.5 text-center inline-flex items-center me-2 ml-20" >
              Export
              <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg" class="animate-bounce hover:animate-spin">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M2 12C2 7.28595 2 4.92893 3.46447 3.46447C4.92893 2 7.28595 2 12 2C16.714 2 19.0711 2 20.5355 3.46447C22 4.92893 22 7.28595 22 12C22 16.714 22 19.0711 20.5355 20.5355C19.0711 22 16.714 22 12 22C7.28595 22 4.92893 22 3.46447 20.5355C2 19.0711 2 16.714 2 12ZM12 6.25C12.4142 6.25 12.75 6.58579 12.75 7V12.1893L14.4697 10.4697C14.7626 10.1768 15.2374 10.1768 15.5303 10.4697C15.8232 10.7626 15.8232 11.2374 15.5303 11.5303L12.5303 14.5303C12.3897 14.671 12.1989 14.75 12 14.75C11.8011 14.75 11.6103 14.671 11.4697 14.5303L8.46967 11.5303C8.17678 11.2374 8.17678 10.7626 8.46967 10.4697C8.76256 10.1768 9.23744 10.1768 9.53033 10.4697L11.25 12.1893V7C11.25 6.58579 11.5858 6.25 12 6.25ZM8 16.25C7.58579 16.25 7.25 16.5858 7.25 17C7.25 17.4142 7.58579 17.75 8 17.75H16C16.4142 17.75 16.75 17.4142 16.75 17C16.75 16.5858 16.4142 16.25 16 16.25H8Z" fill="white"/>
              </svg>
            </button>
        </div>
        </div>
      </div>

  <div class="outer">

  {/* <!-- Location Dropdown --> */}

    <div class="dropdownone">
      <label class="dropdownlabel">Choose Location</label>
      <select
        onChange={dochoosedlocation}
        value={choosedloc}
        class="dropdownbutton"
      >
        <option value="" class="dropdownoption">All Locations</option>
        {location.map((loc) => (
          <option key={loc._id} value={loc._id} class="dropdownoption">
            {loc.locationname}
          </option>
        ))}
      </select>
    </div>

  {/* <!-- Department Dropdown --> */}

    <div class="dropdownone">
      <label class="dropdownlabel">Choose Department</label>
      <select
        onChange={dochooseddepartment}
        value={chooseddep}
        class="dropdownbutton"
      >
        <option value="" class="dropdownoption">All Departments</option>
        {department.map((dep) => (
          <option key={dep._id} value={dep.departmentname} class="dropdownoption">
            {dep.departmentname}
          </option>
        ))}
      </select>
    </div>

  {/* <!-- Status Dropdown --> */}

    <div class="dropdownone">
      <label class="dropdownlabel">Choose Status</label>
      <select
        onChange={dochoosedpending}
        value={choosedpen}
        class="dropdownbutton"
      >
        <option value="" class="dropdownoption">All Status</option>
        <option value="Pending" class="dropdownoption">Pending</option>
        <option value="Completed" class="dropdownoption">Completed</option>
      </select>
    </div>


    

  {/* <!-- Toucyhed Dropdown --> */}

    <div class="dropdownone">
      <label class="dropdownlabel">Choose Touched</label>
      <select 
        onChange={dochoosedUntouched} value={choosedUntouched} 
         class="dropdownbutton">
          <option value="" class="dropdownoption">All Forms</option>
          <option value="false" class="dropdownoption">Not Opened</option>
          <option value="true" class="dropdownoption">Opened</option>
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

  {/* <!-- Search Form --> */}

  
    <div class="flex w-96 bg-white ml-12 px-3 rounded-lg items-center border border-gray-300 transition-all ease-in-out hover:border-blue-700 focus:border-gray-500 ">
    <div className="text-gray-600">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" width="24" height="24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M11 4a7 7 0 1 1-4.95 11.95l-3.95 3.95a1 1 0 0 1-1.414-1.414l3.95-3.95A7 7 0 0 1 11 4z" />
      </svg>


      </div>
      <input
        type="search"
        class="block w-full p-4 text-sm text-gray-900  focus:outline-none   "
        placeholder="Search by subject..."
        required
        value={subject}
        onChange={handlesubject}
      />

      

      
      
    </div>

    
  

  {/* <!-- Clear Filter Button --> */}
  
    <div class="ml-auto">
      <button
        onClick={clearfilter}
        class="hover:bg-red-600 flex items-center shadow-lg gap-2 shadow-red-500 text-white bg-red-700 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-base px-5 py-2.5"
        >
        Clear Filter
        <svg fill="white" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlnsXlink="http://www.w3.org/1999/xlink" 
      width="23px" height="24px" viewBox="0 0 42 42" xmlSpace="preserve">
          <path fill-rule="evenodd" d="M21.002,26.588l10.357,10.604c1.039,1.072,1.715,1.083,2.773,0l2.078-2.128
            c1.018-1.042,1.087-1.726,0-2.839L25.245,21L36.211,9.775c1.027-1.055,1.047-1.767,0-2.84l-2.078-2.127
            c-1.078-1.104-1.744-1.053-2.773,0L21.002,15.412L10.645,4.809c-1.029-1.053-1.695-1.104-2.773,0L5.794,6.936
            c-1.048,1.073-1.029,1.785,0,2.84L16.759,21L5.794,32.225c-1.087,1.113-1.029,1.797,0,2.839l2.077,2.128
            c1.049,1.083,1.725,1.072,2.773,0L21.002,26.588z"/>
          </svg>
      </button>
     </div>



     <div class="tableout">
      <table class="table">
          <thead class= "tablehead">
            <tr class="px-6 py-3 ">
              <th class="tc">S.no</th>
              <th class="tc">From Department</th>
              <th class="tc">To Department</th>
              <th class="tc">Subject</th>
              <th class="tc">Status</th>
              <th class="tc">Touched</th>
              <th class="tc">Mongo</th>
              <th class="tc">Actions</th>
              
            </tr>
          </thead>
        <tbody>
          {currentForms.map((form, index) => (
            <tr key={form._id} class={`h-16 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-100'} hover:bg-gray-300 text-lg`}>
              <td class="tc">{index + 1}</td>
              <td class="tc">{form.fromdepartment}</td>
              <td class="tc">{form.todepartment}</td>
              <td
                className="max-w-xs truncate overflow-hidden text-ellipsis whitespace-nowrap"
                title={form.subject} 
              >
                {form.subject}
              </td>



              <td class="tc">{form.status === 'Completed' ? 
              (
                <span className="flex items-center text-green-500">
                  Completed
                  <svg className="w-5 h-5 mx-5" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M8.293 12.293a1 1 0 0 1 1.414 0L14 8.707l1.414 1.414-7.707 7.707a1 1 0 0 1-1.414 0L4 11.707 5.414 10l2.879 2.879z" />Completed
                  </svg>
                </span>
              ) 
              : 
              (
                <span className="flex items-center text-red-500">
                   Pending
                  <svg className="w-5 h-5 mx-9" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-1-11h2v6h-2z" />
                  </svg>
                  </span>
              )
              }</td>

              <td class="tc">{form.opened ? 
               (
                <span className="flex items-center text-green-500">
                  Opened
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 mx-5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 4.5c-4.974 0-9.189 3.065-11 7.5 1.811 4.435 6.026 7.5 11 7.5s9.189-3.065 11-7.5c-1.811-4.435-6.026-7.5-11-7.5zm0 12a4.5 4.5 0 110-9 4.5 4.5 0 010 9zm0-7.5a3 3 0 100 6 3 3 0 000-6z" />
                  </svg>


                </span>
              ) 
              :(
                <span className="flex items-center text-red-500">
                   Still no
                   <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 mx-7" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 4.5c-4.974 0-9.189 3.065-11 7.5a12.59 12.59 0 003.128 4.33l-2.2 2.2a.75.75 0 101.06 1.06l18-18a.75.75 0 10-1.06-1.06l-2.2 2.2A12.59 12.59 0 0012 4.5zm6.872 3.572L6.39 20.554A11.825 11.825 0 0012 19.5c4.974 0 9.189-3.065 11-7.5a12.59 12.59 0 00-3.128-4.33zM12 9a3 3 0 012.598 1.5L9 15.098A3 3 0 0112 9zm0 6a3 3 0 01-2.598-1.5l5.598-5.598A3 3 0 0112 15z" />
                  </svg>

                  </span>
              )}</td>
                <td className="tc cursor-pointer hover:text-blue-500 text-pink-500 hover:underline" title="Click to Copy" onClick={() => clipboard(form._id)} >{form._id}</td>
              
              <td>

              <div class="flex items-center space-x-9">
                  <div >
                  <button onClick={() => viewmore(form)} className="update">View
                  
                  


                  <svg 
                    fill="white" 
                    version="1.1" 
                    id="Capa_1" 
                    xmlns="http://www.w3.org/2000/svg" 
                    width="23px" 
                    height="23px" 
                    viewBox="0 0 866.929 866.93"
                  >
                    <g>
                    <path d="M144.465,450.93c7.8,46.7,58.9,155.399,159.8,257.5v55.3h362.401v-55v-0.3l36.6-61.5c13.101-21.9,20-47,20-72.5v-187.7
                                        c-0.3-16.3-19.199-32.6-45-37.6c-20.5-4-39.6,0.199-49.8,9.6c-0.3-16.3-19.1-32.6-44.899-37.7c-18.5-3.7-36-0.6-46.7,7
                                        c-3.2-15-21.9-29.2-46.601-34.1c-21.3-4.2-41.199-0.2-51.8,9.1h-0.1c0,0,0,0,0-0.1c-0.5-4.9-27.901-270.3-28-270.7
                                        c-5.101-46.8-81.2-40.7-81.101,5.8l-0.199,436.5c0,5.2-3.801,9.5-8.9,10.2c-0.1,0-0.1,0-0.2,0c-0.6,0.1-1.1,0.1-1.7,0.1
                                        c-14.699-0.399-47.8-0.899-80.1-47.6c-4.3-6.2-8.2-11.8-11.7-16.9C195.865,376.229,136.065,400.63,144.465,450.93z"/>
                                      <path d="M304.465,846.93c0,11,9,20,20,20h322.5c11,0,20-9,20-20v-51.101h-362.5V846.93z"/>
                    </g>
                  </svg>
                  </button>




                  </div>
 

                  

                  <button onClick={() => openconfirm(form._id)} className="delete">
                    Delete
                    



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

                  </button>

                    
                    {/* Flowbite Modal */}
                    <Modal show={showdelete}   onClose={() => setshowdelete(false)} popup className="bg-gray-600 h-1/4 w-1/4 m-auto rounded-lg">
                      <Modal.Header class="bg-gray-600" />
                      <Modal.Body class="bg-gray-600">
                        <div className="text-center  m-aut0 bg-gray-600">
                          <HiOutlineExclamationCircle className="mx-auto mb-4 h-14 w-14 text-white" />
                          <h3 className="mb-5 text-lg font-normal text-white">
                            Are you sure you want to delete Form?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            <button className="delete" onClick={() => confirmdelete(deleteid)}>
                              Delete
                            </button>
                            <Button color="gray" onClick={() => {setshowdelete(false); (toast.error("Progress Canceled"))}}>
                              Cancel
                            </Button>
                          </div>
                        </div>
                      </Modal.Body>
                    </Modal>

                    {/* <Modal show={showmore && choosed}   onClose={() => setshowmore(false)} popup >
                      <Modal.Header class="bg-gray-600" />
                      <Modal.Body class="bg-gray-600">
                        <div className="text-center   bg-gray-600">
                          <HiOutlineExclamationCircle className=" text-white" />
                          <h3 className=" text-lg font-normal text-white">
                            Are you sure you want to delete Form?
                          </h3>
                          <div className="flex justify-center gap-4 mb-10 ">
                            
                            <Button color="gray" onClick={() => {setshowmore(false); (toast.error("Progress Canceled"))}}>
                              Close
                            </Button>
                          </div>
                        </div>
                      </Modal.Body>
                    </Modal> */}
                      
              </div>
            </td>
            
           </tr>
          ))}
        </tbody>
      </table>
    </div>
   </div>

    
 

      {/* Forms Table */}
      
    

    <div className="mt-4 flex justify-center  ">
        <Pagination className="bg-green-300 rounded-lg"
          currentPage={currentPage}
          totalPages={Math.ceil(filterforms.length / itemsPerPage)}
          onPageChange={handlePaginationChange}
        />
      </div>

      {/* View More Section */}
      {showmore && choosed && (
        <div className="viewm">
          <h3>Form Details</h3>
          <button onClick={closeall}>Close</button>
          <p>From: {choosed.fromdepartment}</p>
          <p>To: {choosed.todepartment}</p>
          <p>Subject: {choosed.subject}</p>
          <p>Description : {choosed.description}</p>
          <p>Status: {choosed.status}</p>
          <p>Clinical: {choosed.clinical}</p>
          <p>Operational: {choosed.operational}</p>
          <p>Persons Involved: {choosed.personsinvolved}</p>
          <p>Date: {choosed.createdtime}</p>


        {responseform && (
            <div>
                 <h4>Response Details</h4>
                 <p><strong>Explanation:</strong> {responseform.explanation}</p>
                 <p>Causes: {responseform.causes}</p>
                 <p>Prevented? :{responseform.isprevented}</p>
                 <p>Future preventive measures: {responseform.futurepreaction}</p>
                 <p>Immediate Action : {responseform.immediate}</p>
                 <p>Action Type :{responseform.actiontype}</p>
                 <p>Responsible for implementation : {responseform.resofimple}</p>
                 <p>CAPA Done by: {responseform.capa}</p>
                 <p>Responsedn time : {responseform.createdtime}</p>

            </div>
        )}


        </div>

        
      )}
    </div>
  );
};

export default Mainform;
